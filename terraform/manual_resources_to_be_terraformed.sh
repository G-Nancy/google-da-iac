
PROJECT=pso-erste-digital-sandbox

gcloud artifacts repositories create dataplatform \
    --repository-format=docker \
    --location=europe-west3

#gcloud storage buckets create gs://pso-erste-digital-sandbox-dataflow --location=europe-west3
#
#gcloud storage buckets create gs://pso-erste-digital-sandbox-data --location=europe-west3


###### Tables

#bq mk \
#--table \
#pso-erste-digital-sandbox:erste_bq_landing.customer_stg \
#modules/bigquery-core/schema/landing/customer_stg.json

#bq mk \
#--table \
#pso-erste-digital-sandbox:erste_bq_curated.customer \
#modules/bigquery-core/schema/curated/customer.json
#
#bq mk \
#--table \
#pso-erste-digital-sandbox:erste_bq_curated.customer_score \
#modules/bigquery-core/schema/curated/customer_score.json
#
#bq mk \
#--table \
#pso-erste-digital-sandbox:erste_bq_curated.failed_customer_processing \
#modules/bigquery-core/schema/curated/failed_record_processing.json

######  Dataflow worker service account

gcloud iam service-accounts create dataflow-temp \
    --description="temp dataflow workers SA until terraformed" \
    --display-name="dataflow-temp"

gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --role="roles/dataflow.admin"

gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --role="roles/dataflow.worker"

# to read flex template files from GCS and read-write files
gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

# Grant iam.serviceAccountTokenCreator & Service Account User  on dataflow-temp@ to Compute Engine Service Agent
gcloud iam service-accounts add-iam-policy-binding \
    "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --member=serviceAccount:service-634617552237@compute-system.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountTokenCreator

gcloud iam service-accounts add-iam-policy-binding \
    "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --member=serviceAccount:service-634617552237@compute-system.iam.gserviceaccount.com \
    --role=roles/iam.serviceAccountUser

# Grant iam.serviceAccountTokenCreator & Service Account User  on dataflow-temp@ to Dataflow Service Agent
gcloud iam service-accounts add-iam-policy-binding \
    "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --member="serviceAccount:service-634617552237@dataflow-service-producer-prod.iam.gserviceaccount.com" \
    --role=roles/iam.serviceAccountTokenCreator

gcloud iam service-accounts add-iam-policy-binding \
    "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --member="serviceAccount:service-634617552237@dataflow-service-producer-prod.iam.gserviceaccount.com" \
    --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.reader"

    # to create bigquery load/query jobs
gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --role="roles/bigquery.jobUser"

    # to create tables and load data
gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --role="roles/bigquery.dataEditor"

    # to invoke cloud run
gcloud projects add-iam-policy-binding ${PROJECT} \
    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
    --role="roles/run.invoker"

#######  Composer service account
#
#gcloud iam service-accounts create composer-temp \
#    --description="temp composer SA until terraformed" \
#    --display-name="composer-temp"
#
#gcloud projects add-iam-policy-binding ${PROJECT} \
#    --member="serviceAccount:composer-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --role="roles/composer.worker"
#
#gcloud projects add-iam-policy-binding ${PROJECT} \
#    --member="serviceAccount:composer-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --role="roles/iam.serviceAccountUser"
#
#    # to create bigquery load/query jobs
#gcloud projects add-iam-policy-binding ${PROJECT} \
#    --member="serviceAccount:composer-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --role="roles/bigquery.jobUser"
#
#    # to create tables and load data
#gcloud projects add-iam-policy-binding ${PROJECT} \
#    --member="serviceAccount:composer-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --role="roles/bigquery.dataEditor"
#
#    # to submit dataflow jobs
#gcloud projects add-iam-policy-binding ${PROJECT} \
#    --member="serviceAccount:composer-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --role="roles/dataflow.admin"
#


# Cloud Run - Example Customer Scoring Service

gcloud iam service-accounts create cr-customer-scoring-temp \
    --description="temp customer scoring cloud run SA until terraformed" \
    --display-name="cr-customer-scoring-temp"

# This is needed to manually deploy CR service with a custom service account
# Probably it's not needed when using Terraform
gcloud iam service-accounts add-iam-policy-binding ${CUSTOMER_SCORING_SA_EMAIL} \
        --member "user:admin@wadie.joonix.net" \
        --role "roles/iam.serviceAccountUser"