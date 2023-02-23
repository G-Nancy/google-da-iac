from datetime import timedelta
from airflow import DAG
from airflow.utils.dates import days_ago
import os
from airflow.providers.google.cloud.operators.dataproc import DataprocSubmitJobOperator, DataprocCreateClusterOperator, \
    DataprocDeleteClusterOperator
from airflow.operators.python_operator import BranchPythonOperator
from airflow.operators.dummy_operator import DummyOperator

# variables that we get from the Composer environment
env = os.environ.get('env')  # Airflow variable, with possible values 'dev', 'int' and 'prd'. Some Python variables
project = os.environ.get('project')
dataflow_flex_template_spec = os.environ.get('customer_dataflow_flex_template_spec')
dataflow_temp_bucket = os.environ.get('dataflow_temp_bucket')
dataflow_service_account_email = os.environ.get('dataflow_service_account_email')
compute_region = os.environ.get('compute_region')
compute_zone = os.environ.get('compute_zone')
bq_landing_dataset = os.environ.get('bq_landing_dataset')
bq_curated_dataset = os.environ.get('bq_curated_dataset')
customer_scoring_url = os.environ.get('customer_scoring_url')

data_bucket = f'{project}-customer-data'  # Bucket for data processing
landing_folder = 'landing'  # Folder for landing input data (from original data source to GCS).
processing_folder = 'processing'  # Folder for input data that is being processed.
archive_folder = 'archive'  # Folder for archived input data.
pipeline_name = "customer_ingestion_dag"
# bq table where we ingest the new incoming batch
bq_customer_stg_table = f'{project}.{bq_landing_dataset}.customer_stg'
# bq table where we keep history of all customers after updating them with the new batch
bq_customer_history_table = f'{project}.{bq_curated_dataset}.customer'
# bq table where we keep history of all customers after updating them with the new batch
bq_customer_score_table = f'{project}.{bq_curated_dataset}.customer_score'
bq_error_table = f'{project}.{bq_curated_dataset}.failed_customer_processing'

# this MySql instance is created during the repo deployment (i.e. README.md)
my_sql_instance_name = "mysql-instance"
my_sql_instance_port = "3307"

sqoop_import_target_dir = f"gs://{project}-customer-data/landing/"

# this login file is created during the repo deployment (i.e. README.md)
my_sql_instance_password_file_uri = f"gs://{project}-resources/mysql/login.txt"

dag_run_id = '{{ dag_run.logical_date | ts_nodash | lower }}'
cluster_name = f'cluster-{dag_run_id}'

default_args = {
    'start_date': days_ago(2),
    'email': ['composer-admin@example.com'],
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 0,
    # 'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'data-import-customer',
    default_args=default_args,
    description='Example DAG for importing customer data via Sqoop on Dataproc',
    #TODO: set the desired frequency for the dag
    # schedule_interval=timedelta(minutes=60),
    schedule_interval=None,
    dagrun_timeout=timedelta(minutes=30),
    catchup=False,
    concurrency=1,  # number of parallel operators/tasks that can run in this DAG.
    max_active_runs=1,  # number of parallel DAG runs
    # location on Airflow to lookup for resource files (e.g. SQL)
    template_searchpath=['/home/airflow/gcs/data/sql/']
)

#TODO: create cluster with internal IP only
#TODO: Add a persistent history dataproc server to save logs and job history from ephemeral clusters
create_cluster = DataprocCreateClusterOperator(
    task_id="create_cluster",
    dag=dag,
    project_id=project,
    region=compute_region,
    cluster_name=cluster_name,
    # ref: cluster configuration parameters https://cloud.google.com/dataproc/docs/reference/rest/v1/ClusterConfig
    cluster_config={
            "master_config": {
                "num_instances": 1,
                "machine_type_uri": "n1-standard-4",
                "disk_config": {"boot_disk_type": "pd-standard", "boot_disk_size_gb": 500},
            },
            "worker_config": {
                "num_instances": 2,
                "machine_type_uri": "n1-standard-4",
                "disk_config": {"boot_disk_type": "pd-standard", "boot_disk_size_gb": 500},
            },
            "initialization_actions": [
                {
                    # FIXME: this is not needed while using any other Database to pull data from
                    "executable_file": f"gs://goog-dataproc-initialization-actions-{compute_region}/cloud-sql-proxy/cloud-sql-proxy.sh"
                }

            ],
            "gce_cluster_config": {
                "zone_uri": f"https://www.googleapis.com/compute/v1/projects/{project}/zones/{compute_zone}",
                "network_uri": f"https://www.googleapis.com/compute/v1/projects/{project}/global/networks/default",
                "service_account_scopes": [
                    "https://www.googleapis.com/auth/cloud.useraccounts.readonly",
                    "https://www.googleapis.com/auth/devstorage.read_only",
                    "https://www.googleapis.com/auth/devstorage.read_write",
                    "https://www.googleapis.com/auth/logging.write",
                    "https://www.googleapis.com/auth/monitoring.write",
                    "https://www.googleapis.com/auth/pubsub",
                    "https://www.googleapis.com/auth/service.management.readonly",
                    "https://www.googleapis.com/auth/servicecontrol",
                    "https://www.googleapis.com/auth/sqlservice.admin",
                    "https://www.googleapis.com/auth/trace.append"
                ],
                "metadata": {
                    "additional-cloud-sql-instances": f"{project}:{compute_region}:{my_sql_instance_name}=tcp:{my_sql_instance_port}",
                    "enable-cloud-sql-hive-metastore": "false"
                }
            }
    }
)

sqoop_import = DataprocSubmitJobOperator(
    task_id="sqoop_import",
    dag=dag,
    region=compute_region,
    project_id=project,
    job={
        "hadoop_job": {
            "jar_file_uris": [
                f"gs://{project}-resources/dataproc/jars/sqoop-1.4.7-hadoop260.jar",
                f"gs://{project}-resources/dataproc/jars/avro-tools-1.8.2.jar",
                f"gs://{project}-resources/dataproc/jars/mysql-connector-java-8.0.29.jar"
            ],
            "args": [
                "import",
                "-Dmapreduce.job.user.classpath.first=true",
                "-Dmapreduce.job.classloader=true",
                f"--connect=jdbc:mysql://localhost:{my_sql_instance_port}/customers",
                "--username=root",
                f"--password-file={my_sql_instance_password_file_uri}",
                f"--target-dir={sqoop_import_target_dir}",
                "--table=customer",
                "--delete-target-dir",
                "--fields-terminated-by=,",
                "--as-textfile"
                # "--as-avrodatafile",
                # "--columns=first_name,last_name",
            ],
            "main_class": "org.apache.sqoop.Sqoop"
        },
        "reference": {"project_id": project},
        "placement": {"cluster_name": cluster_name}
    }
)

def is_cluster_created_callable(**kwargs):
    task_output = kwargs['ti'].xcom_pull(task_ids="create_cluster")
    # If the cluster is created, Dataproc will return the uuid that we can use to check if the task was successful
    if task_output is not None and 'cluster_uuid' in task_output:
        return 'delete_cluster'
    else:
        return 'do_nothing'

is_cluster_created = BranchPythonOperator(
    task_id='is_cluster_created',
    python_callable=is_cluster_created_callable,
    provide_context=True,
    trigger_rule="all_done", # all_done will run this task in case of success or failure of the upstream tasks
    dag=dag
)

delete_cluster = DataprocDeleteClusterOperator(
    task_id="delete_cluster",
    dag=dag,
    project_id=project,
    cluster_name=cluster_name,
    region=compute_region,
)

do_nothing = DummyOperator(task_id='do_nothing', dag=dag)

create_cluster >> sqoop_import >> is_cluster_created >> [delete_cluster, do_nothing]
