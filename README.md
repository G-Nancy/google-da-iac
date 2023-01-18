# erste-digital-poc
Google PSO POC project for Erste Digital - for internal collaboration

# Project
```shell
domain: wadie.joonix.net

project: pso-erste-digital-sandbox
```
# Deploy Terraform

#### Set Variables
```shell
export PROJECT_ID=pso-erste-digital-sandbox
export COMPUTE_REGION=
export ACCOUNT=<current user account email>
export BUCKET=<terraform state bucket>
export TF_SA=<service account name used by terraform>
```

#### Prepare Terraform State Bucket

```shell
gsutil mb -p $PROJECT_ID -l $COMPUTE_REGION -b on gs://$BUCKET
```

#### Prepare Terraform Service Account

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

```shell
./scripts/prepare_terraform_service_account.sh
```

#### Enable GCP APIs

```shell
./scripts/enable_gcp_apis.sh
```


#### Terraform Variables Configuration

The solution is deployed by Terraform and thus all configurations are done
on the Terraform side.

##### Create a Terraform .tfvars file

Create a new .tfvars file and override the variables in the below sections. You can use the example
tfavrs files as a base [example-variables](terraform/example-variables.tfvars).

```shell
export VARS=my-variables.tfvars
```

##### Configure Project Variables

Most required variables have default values defined in [variables.tf](terraform/variables.tf).
One can use the defaults or overwrite them in the newly created .tfvars.

Both ways, one must set the below variables:

```yaml
project = "<GCP project ID to deploy solution to (equals to $PROJECT_ID) >"
compute_region = "<GCP region to deploy compute resources e.g. cloud run, iam, etc (equals to $COMPUTE_REGION)>"
data_region = "<GCP region to deploy data resources (buckets, datasets, tag templates, etc> (equals to $DATA_REGION)"
```

##### Configure Terraform Service Account

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

This service account name is defined in the "Setup Environment Variables" step and created
in the "Prepare Terraform Service Account" step.
Use the full email of the created account.
```yaml
terraform_service_account = "${TF_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
```

#### Deploy Terraform

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

```shell
./scripts/deploy_terraform.sh
```

#### Enable Google Private Access

* We're using the default VPC
* To use dataflow with private IPs one must enable Google Private Access on the subnetwork.
```shell
gcloud compute networks subnets update <SUBNETWORK> \
--region=<REGION> \
--enable-private-ip-google-access
```
* On the customer project, a shared VPC is expected and the subnetwork has to enable Google Private Access. Dataflow jobs are then submitted
  to the desired subnetwork via the --subnetwork param

# Dataflow
## Deploy Dataflow Batch Job(s)

Set and export the following variables:

```shell
export PROJECT=<dataflow project>
export REGION=<dataflow region>
export DOCKER_REPO=<docker repo name - created by terraform>
export PIPELINE_NAME=batch-example-java
export POM_PATH="dataflow/batch/dataflow-batch-example-java/pom.xml"
export FLEX_DOCKER_PATH="dataflow/batch/dataflow-batch-example-java/Dockerfile"
export FLEX_META_DATA_PATH="dataflow/batch/dataflow-batch-example-java/metadata.json"
export JAVA_JAR="dataflow/batch/dataflow-batch-example-java/target/dataflow-batch-example-java-bundled-1.0.jar"
export JAVA_MAIN_CLASS="com.google.cloud.pso.BatchExamplePipeline"
export IMAGE_BUILD_VERSION=1.0
export FLEX_TEMPLATE_PATH=gs://<dataflow bucket created by terraform>/flex-templates/${PIPELINE_NAME}/${PIPELINE_NAME}-metadata.json
```
  
Run the deployment script
```shell
. scripts/deploy_dataflow_flex_template.sh 
```

Repeat the process to deploy newly added jobs


## Run Dataflow Batch Job

To run the `dataflow-batch-example-java` job via the deployed Flex-Template:

Set and export these additional variables:
```shell

export DATAFLOW_BUCKET=<dataflow resourses bucket created by terraform>
export JOB_PARAM_INPUT_TABLE=<dataset.table>
export JOB_PARAM_OUTPUT_TABLE=<dataset.table>
export JOB_PARAM_ERROR_TABLE=<dataset.table>
export JOB_PARAM_SERVICE_URL=<customer scoring service deployed by Terraform>
export JOB_WORKER_TYPE=n2-standard-2
export JOB_WORKERS_COUNT=1
export DATAFLOW_SERVICE_ACCOUNT_EMAIL=<dataflow sa deployed by Terraform>
```

Run the following command
```shell
RUN_ID=`date +%Y%m%d-%H%M%S`
gcloud dataflow flex-template run "batch-example-flex-${RUN_ID}" \
    --template-file-gcs-location ${FLEX_TEMPLATE_PATH} \
    --parameters inputTable=${JOB_PARAM_INPUT_TABLE} \
    --parameters outputTable=${JOB_PARAM_OUTPUT_TABLE} \
    --parameters errorTable=${JOB_PARAM_ERROR_TABLE} \
    --parameters customerScoringServiceUrl=${JOB_PARAM_SERVICE_URL} \
    --temp-location "gs://${DATAFLOW_BUCKET}/runs/batch-example-java/${RUN_ID}/temp/" \
    --staging-location "gs://${DATAFLOW_BUCKET}/runs/batch-example-java/${RUN_ID}/stg/" \
    --worker-machine-type ${JOB_WORKER_TYPE} \
    --region ${REGION} \
    --num-workers ${JOB_WORKERS_COUNT} \
    --disable-public-ips \
    --service-account-email=${DATAFLOW_SERVICE_ACCOUNT_EMAIL}
```


