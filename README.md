# erste-digital-poc
Google PSO POC project for Erste Digital - for internal collaboration

# Deployment

#### Set Variables
```shell
export PROJECT_ID=<gcp project>
export COMPUTE_REGION=<region to deploy compute resources>
export DATA_REGION=<region to deploy data resources>
export ACCOUNT=<current user account email>
export TF_BUCKET="${PROJECT_ID}_terraform"
export TF_SA=sa-terraform
export DOCKER_REPOSITORY_NAME=data-platform-docker-repo
```

#### gcloud config

Create (or activate) a gcloud config profile for this project
```shell
export CONFIG=<config name for gcloud>

gcloud config configurations create $CONFIG
gcloud config set project $PROJECT_ID
gcloud config set account $ACCOUNT
gcloud config set compute/region $COMPUTE_REGION

gcloud auth login
gcloud auth application-default login
```

#### Enable GCP APIs

```shell
./scripts/enable_gcp_apis.sh
```

#### Prepare Terraform State Bucket

```shell
gsutil mb -p $PROJECT_ID -l $COMPUTE_REGION -b on gs://${TF_BUCKET}
```

#### Prepare Terraform Service Account

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

```shell
./scripts/prepare_terraform_service_account.sh
```

#### Create a Docker Repo

```shell
./scripts/create_artifact_registry.sh
```

#### Enable Google Private Access

* We're using the default VPC
* To use dataflow with private IPs one must enable Google Private Access on the subnetwork.
```shell
gcloud compute networks subnets update default \
--project=${PROJECT_ID} \
--region=${COMPUTE_REGION} \
--enable-private-ip-google-access
```
* On the customer project, a shared VPC is expected and the subnetwork has to enable Google Private Access. Dataflow jobs are then submitted
  to the desired subnetwork via the --subnetwork param

#### Build Service(s) Image(s)

Build the docker image that will be used for the customer scoring service.
The image is pushed to Artifact Registry and will be later used by Cloud Run.
```shell

export CUSTOMER_SCORING_IMAGE="${COMPUTE_REGION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPOSITORY_NAME}/services/example-customer-scoring-java:latest"

mvn -f services/example-customer-scoring-java/pom.xml \
compile jib:build \
-Dimage="${CUSTOMER_SCORING_IMAGE}"
```


#### Configure Terraform Variables

Create a new `variables.tfvars` file and override the variables in the below sections.

```shell
export VARS=variables.tfvars
```

Most required variables have default values defined in [variables.tf](terraform/variables.tf).
One can use the defaults or overwrite them in the newly created .tfvars.

Both ways, one must set the below variables:

```yaml
deployment_version = "<major.minor> (this should be automated by the CICD pipeline)"
project = "<GCP project ID to deploy solution to (equals to $PROJECT_ID) >"
compute_region = "<GCP region to deploy compute resources e.g. cloud run, iam, etc (equals to $COMPUTE_REGION)>"
data_region = "<GCP region to deploy data resources (buckets, datasets, tag templates, etc> (equals to $DATA_REGION)"
terraform_service_account = " equals to ${TF_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
artifact_repo_name = "equals to ${DOCKER_REPOSITORY_NAME}"
customer_scoring_service_image = "equals to ${COMPUTE_REGION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPOSITORY_NAME}/services/example-customer-scoring-java:latest"
customer_dataflow_flex_template_spec = "equals to gs://${PROJECT_ID}-dataflow/flex-templates/batch-example-java/batch-example-java-metadata.json"
```

#### Deploy Terraform

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

```shell
./scripts/deploy_terraform.sh
```

PS: Creating the Cloud Composer environment for the first time can drag Terraform operation to up to 20 mins.

#### Deploy Dataflow Batch Job(s)

Set and export the following variables:

```shell
export PIPELINE_NAME=batch-example-java
export POM_PATH="dataflow/customer-pipeline-examples/pom.xml"
export FLEX_DOCKER_PATH="dataflow/customer-pipeline-examples/resources-batch/Dockerfile"
export FLEX_META_DATA_PATH="dataflow/customer-pipeline-examples/resources-batch/metadata.json"
export JAVA_JAR="dataflow/customer-pipeline-examples/target/customer-pipeline-examples-bundled-1.0.jar"
export JAVA_MAIN_CLASS="com.google.cloud.pso.BatchExamplePipeline"
export IMAGE_BUILD_VERSION=1.0
export FLEX_TEMPLATE_PATH=gs://${PROJECT_ID}-dataflow/flex-templates/${PIPELINE_NAME}/${PIPELINE_NAME}-metadata.json
```
  
Run the deployment script
```shell
. scripts/deploy_dataflow_flex_template.sh 
```

#### Deploy Dataflow Streaming Job(s)

Set and export the following variables:

```shell
export PIPELINE_NAME=streaming-example-java
export POM_PATH="dataflow/customer-pipeline-examples/pom.xml"
export FLEX_DOCKER_PATH="dataflow/customer-pipeline-examples/resources-streaming/Dockerfile"
export FLEX_META_DATA_PATH="dataflow/customer-pipeline-examples/resources-streaming/metadata.json"
export JAVA_JAR="dataflow/customer-pipeline-examples/target/customer-pipeline-examples-bundled-1.0.jar"
export JAVA_MAIN_CLASS="com.google.cloud.pso.StreamingExamplePipeline"
export IMAGE_BUILD_VERSION=1.0
export FLEX_TEMPLATE_PATH=gs://${PROJECT_ID}-dataflow/flex-templates/${PIPELINE_NAME}/${PIPELINE_NAME}-metadata.json
```

Run the deployment script
```shell
. scripts/deploy_dataflow_flex_template.sh 
```

Repeat the process to deploy newly added jobs

#### Deploy Composer Artifacts

```shell
export COMPOSER_BUCKET_NAME=<created by Composer>
export DATA_BUCKET_CUSTOMERS=${PROJECT_ID}-customer-data

. scripts/deploy_composer_artifacts.sh
```

# Testing

## Testing the Batch Pipeline

Create sample test data on GCS
```shell
DATA_BUCKET_CUSTOMERS=${PROJECT_ID}-customer-data

. scripts/deploy_sample_data.sh
```
Run the customer ingestion DAG from the Airflow UI


## Testing Dataflow Streaming Job

To run the `dataflow-streaming-example-java` job via the deployed Flex-Template:

Set and export these additional variables:
```shell
export PIPELINE_NAME=streaming-example-java
export FLEX_TEMPLATE_PATH=gs://${PROJECT_ID}-dataflow/flex-templates/${PIPELINE_NAME}/${PIPELINE_NAME}-metadata.json
export DATAFLOW_BUCKET=${PROJECT_ID}-dataflow
export JOB_PARAM_INPUT_SUBSCRIPTION=projects/$PROJECT_ID/subscriptions/customer-pull-sub
export JOB_PARAM_OUTPUT_TABLE=curated.customer_score
export JOB_PARAM_ERROR_TABLE=curated.failed_record_processing
export JOB_PARAM_SERVICE_URL="<customer scoring service deployed by Terraform>/api/customer/score"
export JOB_WORKER_TYPE=n2-standard-2
export JOB_WORKERS_COUNT=1
export DATAFLOW_SERVICE_ACCOUNT_EMAIL=dataflow-sa@${PROJECT_ID}.iam.gserviceaccount.com
```

Run the following command
```shell
RUN_ID=`date +%Y%m%d-%H%M%S`
gcloud dataflow flex-template run "${PIPELINE_NAME}-flex-${RUN_ID}" \
    --enable-streaming-engine \
    --template-file-gcs-location ${FLEX_TEMPLATE_PATH} \
    --parameters inputSubscription=${JOB_PARAM_INPUT_SUBSCRIPTION} \
    --parameters outputTable=${JOB_PARAM_OUTPUT_TABLE} \
    --parameters errorTable=${JOB_PARAM_ERROR_TABLE} \
    --parameters customerScoringServiceUrl=${JOB_PARAM_SERVICE_URL} \
    --temp-location "gs://${DATAFLOW_BUCKET}/runs/${PIPELINE_NAME}/${RUN_ID}/temp/" \
    --staging-location "gs://${DATAFLOW_BUCKET}/runs/${PIPELINE_NAME}/${RUN_ID}/stg/" \
    --worker-machine-type ${JOB_WORKER_TYPE} \
    --region ${COMPUTE_REGION} \
    --num-workers ${JOB_WORKERS_COUNT} \
    --disable-public-ips \
    --service-account-email=${DATAFLOW_SERVICE_ACCOUNT_EMAIL}
```

Publish sample data to the topic:
```shell
export TOPIC_ID=projects/$PROJECT_ID/topics/customer-topic

. scripts/publish_sample_data.sh
```

Cancel the pipeline:
```shell
gcloud dataflow jobs cancel JOB_ID --region=${COMPUTE_REGION}
```

PS: One can find the JOB_ID in the output of `gcloud dataflow jobs run` command


# Dataflow

## Run Dataflow Batch Job

To run the `dataflow-batch-example-java` job via the deployed Flex-Template:

Set and export these additional variables:
```shell
export PIPELINE_NAME=batch-example-java
export FLEX_TEMPLATE_PATH=gs://${PROJECT_ID}-dataflow/flex-templates/${PIPELINE_NAME}/${PIPELINE_NAME}-metadata.json
export DATAFLOW_BUCKET=<dataflow resourses bucket created by terraform>
export JOB_PARAM_INPUT_TABLE=curated.customer
export JOB_PARAM_OUTPUT_TABLE=curated.customer_score
export JOB_PARAM_ERROR_TABLE=curated.failed_record_processing
export JOB_PARAM_SERVICE_URL="<customer scoring service deployed by Terraform>/api/customer/score"
export JOB_WORKER_TYPE=n2-standard-2
export JOB_WORKERS_COUNT=1
export DATAFLOW_SERVICE_ACCOUNT_EMAIL=dataflow-sa@${PROJECT_ID}.iam.gserviceaccount.com
```

Run the following command
```shell
RUN_ID=`date +%Y%m%d-%H%M%S`
gcloud dataflow flex-template run "${PIPELINE_NAME}-flex-${RUN_ID}" \
    --template-file-gcs-location ${FLEX_TEMPLATE_PATH} \
    --parameters inputTable=${JOB_PARAM_INPUT_TABLE} \
    --parameters outputTable=${JOB_PARAM_OUTPUT_TABLE} \
    --parameters errorTable=${JOB_PARAM_ERROR_TABLE} \
    --parameters customerScoringServiceUrl=${JOB_PARAM_SERVICE_URL} \
    --temp-location "gs://${DATAFLOW_BUCKET}/runs/${PIPELINE_NAME}/${RUN_ID}/temp/" \
    --staging-location "gs://${DATAFLOW_BUCKET}/runs/{${PIPELINE_NAME}/${RUN_ID}/stg/" \
    --worker-machine-type ${JOB_WORKER_TYPE} \
    --region ${COMPUTE_REGION} \
    --num-workers ${JOB_WORKERS_COUNT} \
    --disable-public-ips \
    --service-account-email=${DATAFLOW_SERVICE_ACCOUNT_EMAIL}
```


