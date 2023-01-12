from datetime import timedelta
from airflow import DAG
from airflow.operators.bash_operator import BashOperator
from airflow.operators.python_operator import PythonOperator, BranchPythonOperator
from airflow.contrib.operators import gcs_to_bq, bigquery_operator
from airflow.providers.google.cloud.operators import gcs, bigquery
from airflow.utils.dates import days_ago
from airflow.providers.google.cloud.operators.dataflow import DataflowStartFlexTemplateOperator
from airflow.providers.google.cloud.hooks.dataflow import (_DataflowJobsController, DataflowJobStatus, DataflowJobType)
from airflow.models import Variable
from airflow.operators.dummy_operator import DummyOperator
import os
import airflow_helpers
import functools
from airflow.providers.google.cloud.transfers.gcs_to_gcs import GCSToGCSOperator

# variables that we get from the Composer environment
env = os.environ.get('env')  # Airflow variable, with possible values 'dev', 'int' and 'prd'. Some Python variables
project = os.environ.get('project')
dataflow_flex_template_spec = os.environ.get('customer_dataflow_flex_template_spec')
dataflow_temp_bucket = os.environ.get('dataflow_temp_bucket')
dataflow_service_account_email = os.environ.get('dataflow_service_account_email')
dataflow_region = os.environ.get('dataflow_region')

data_bucket = 'pso-erste-digital-sandbox-data'  # Bucket for data processing
landing_folder = 'customers/landing'  # Folder for landing input data (from original data source to GCS).
processing_folder = 'customers/processing'  # Folder for input data that is being processed.
archive_folder = 'customers/archive'  # Folder for archived input data.
pipeline_name = "customer_ingestion_dag"
# bq table where we ingest the new incoming batch
bq_customer_stg_table = f'{project}.erste_bq_landing.customer_stg'
# bq table where we keep history of all customers after updating them with the new batch
bq_customer_history_table = f'{project}.erste_bq_curated.customer'
# bq table where we keep history of all customers after updating them with the new batch
bq_customer_score_table = f'{project}.erste_bq_curated.customer_score'
bq_error_table = f'{project}.erste_bq_curated.failed_customer_processing'
customer_scoring_url = os.environ.get('customer_scoring_url')

default_args = {
    'start_date': days_ago(2),
    'email': ['composer-admin@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    # 'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'data-ingestion-customer',
    default_args=default_args,
    description='Example DAG for ingesting customer data from GCS to BigQuery.',
    schedule_interval=timedelta(minutes=60),
    dagrun_timeout=timedelta(minutes=30),
    catchup=False,
    concurrency=1,  # number of parallel operators/tasks that can run in this DAG.
    max_active_runs=1, # number of parallel DAG runs
    # location on Airflow to lookup for resource files (e.g. SQL)
    template_searchpath=['/home/airflow/gcs/data/sql/']
)

# Move all files that are in the landing folder to the "processing" folder.
# This is required because we need to archive the successful files and if we do that directly on the "landing" folder
# we run the risk of archiving new unprocessed files that landed during the pipeline processing
move_files_from_landing_to_processing = GCSToGCSOperator(
    task_id='move-files-from-landing-to-processing',
    source_bucket=f'{data_bucket}',
    source_object=f'{landing_folder}/',
    destination_bucket=f'{data_bucket}',
    destination_object=f'{processing_folder}/',
    move_object=True,
    dag=dag
)

# Check if there files in the processing folder. If yes, processed, if not, stop the DAG execution and wait for next run
check_files_in_processing_zone = functools.partial(
    airflow_helpers.check_files_in_bucket,
    bucket=data_bucket,
    folder=processing_folder,
    files_found_branch='load-data-to-stg-bigquery',
    files_not_found_branch='no-files-to-process'
)

check_files_in_processing_zone = BranchPythonOperator(
    task_id='check_files_in_processing_zone',
    python_callable=check_files_in_processing_zone,
    provide_context=True,
    trigger_rule="all_done",
    dag=dag
)

# If data files are there to process, load them to BigQuery stg table
load_data_to_stg_bigquery = gcs_to_bq.GoogleCloudStorageToBigQueryOperator(
    task_id='load-data-to-stg-bigquery',
    bucket=f'{data_bucket}',
    source_objects=[f'{processing_folder}/sample_customers.csv'],
    source_format='CSV',
    compression='NONE',
    field_delimiter=',',
    skip_leading_rows=1,
    destination_project_dataset_table=bq_customer_stg_table,
    write_disposition='WRITE_TRUNCATE',
    create_disposition="CREATE_IF_NEEDED",
    #schema file has to be in the same bucket as the data files. The schema file is deployed in the CICD pipeline.
    schema_object='customers/schema/customer_stg.json',
    dag=dag
)

# UPSERT the new batch of customers from the STG table to the history table
upsert_customers_sql = bigquery_operator.BigQueryOperator(
    task_id='upsert-customers-sql',
    sql='upsert_customers.sql',
    params={'customer_history_table': bq_customer_history_table,
            'customer_staging_table': bq_customer_stg_table},
    use_legacy_sql=False,
    dag=dag
)

# If the new batch is merged successfully to the history table, we archive the source files to avoid re-processing
move_files_from_processing_to_archive = GCSToGCSOperator(
    task_id='move-files-from-processing-to-archive',
    source_bucket=f'{data_bucket}',
    source_object=f'{processing_folder}/',
    destination_bucket=f'{data_bucket}',
    destination_object=f'{archive_folder}/',
    move_object=True,
    dag=dag
)

calculate_scores_dataflow = DataflowStartFlexTemplateOperator(
    task_id=f"calculate-scores-dataflow",
    body={
        "launchParameter": {
            "containerSpecGcsPath": dataflow_flex_template_spec,
            "jobName": "composer-calculate-customer-scores",
            "parameters": {
                "inputTable": bq_customer_history_table,
                "outputTable": bq_customer_score_table,
                "errorTable": bq_error_table,
                "customerScoringServiceUrl": customer_scoring_url,
                # number_of_worker_harness_threads is a fine-tuning param that could be added to the template params. One could use less worker nodes by optimizing it
                # "number_of_worker_harness_threads": "32"
            },
            # https://cloud.google.com/dataflow/docs/reference/rest/v1b3/projects.locations.flexTemplates/launch#flextemplateruntimeenvironment
            "environment": {
                # use sdk_location and sdk_container_image only in case of working with Customer Worker Images
                #"sdkContainerImage": "NA",
                "autoscalingAlgorithm": "AUTOSCALING_ALGORITHM_NONE",
                "enableStreamingEngine": "false",
                "additionalExperiments": "use_runner_v2",
                "tempLocation": f"{dataflow_temp_bucket}/{pipeline_name}/temp/",
                "stagingLocation": f"{dataflow_temp_bucket}/{pipeline_name}/stg/",
                "serviceAccountEmail": dataflow_service_account_email,
                # TODO: use the desired subnetwork on the customer env. The subnetwork has to have "Google Private Access" enabled to access GCP resources
                # "subnetwork": SUBNETWORK,
                # disable public IPs - workers have no internet access
                "ipConfiguration": "WORKER_IP_PRIVATE",
                # num_workers and machineType is a fine-tuning param. Experiment with different settings and monitor resource utilization
                "numWorkers": 1,
                "maxWorkers": 1,
                "machineType": "n2-standard-4",
                "workerRegion": dataflow_region
            },
        }
    },
    location=dataflow_region,
    wait_until_finished=True,
    do_xcom_push=False,  # Default is True. Set to false because it might fail with large xcom data, and we are not using it
    dag=dag
)

no_files_to_process = DummyOperator(task_id='no-files-to-process', dag=dag)

# load the PNR data and materialize required views
move_files_from_landing_to_processing >> check_files_in_processing_zone >> [load_data_to_stg_bigquery, no_files_to_process]
load_data_to_stg_bigquery >> upsert_customers_sql >> move_files_from_processing_to_archive >> calculate_scores_dataflow

