
PROJECT_ID=pso-erste-digital-sandbox

#gcloud artifacts repositories create dataplatform \
#    --repository-format=docker \
#    --location=europe-west3
#
#gcloud storage buckets create gs://pso-erste-digital-sandbox-dataflow --location=europe-west3


######  Dataflow worker service account

#gcloud iam service-accounts create dataflow-temp \
#    --description="temp dataflow workers SA until terraformed" \
#    --display-name="dataflow-temp"
#
#gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --role="roles/dataflow.admin"
#
#gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --role="roles/dataflow.worker"
#
## to read flex template files from GCS and read-write files
#gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#    --member="serviceAccount:dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --role="roles/storage.admin"
#
## Grant iam.serviceAccountTokenCreator & Service Account User  on dataflow-temp@ to Compute Engine Service Agent
#gcloud iam service-accounts add-iam-policy-binding \
#    "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --member=serviceAccount:service-634617552237@compute-system.iam.gserviceaccount.com \
#    --role=roles/iam.serviceAccountTokenCreator
#
#gcloud iam service-accounts add-iam-policy-binding \
#    "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --member=serviceAccount:service-634617552237@compute-system.iam.gserviceaccount.com \
#    --role=roles/iam.serviceAccountUser
#
## Grant iam.serviceAccountTokenCreator & Service Account User  on dataflow-temp@ to Dataflow Service Agent
#gcloud iam service-accounts add-iam-policy-binding \
#    "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --member="serviceAccount:service-634617552237@dataflow-service-producer-prod.iam.gserviceaccount.com" \
#    --role=roles/iam.serviceAccountTokenCreator
#
#gcloud iam service-accounts add-iam-policy-binding \
#    "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
#    --member="serviceAccount:service-634617552237@dataflow-service-producer-prod.iam.gserviceaccount.com" \
#    --role=roles/iam.serviceAccountUser
#
#
###### DATAFLOW SERVICE ACCOUNT PERMISSIONS
#
### dataflow service account  needs access to Artifact registry to pull the flex templates and to GCS to read the json file
#gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#    --member="serviceAccount:service-634617552237@dataflow-service-producer-prod.iam.gserviceaccount.com" \
#    --role="roles/artifactregistry.reader"
#
#gcloud projects add-iam-policy-binding ${PROJECT_ID} \
#    --member="serviceAccount:service-634617552237@dataflow-service-producer-prod.iam.gserviceaccount.com" \
#    --role="roles/storage.reader"


#######  Permissions to create a shared VPC #######

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
    --member="user:admin@wadie.joonix.net" \
    --role="roles/compute.xpnAdmin"
