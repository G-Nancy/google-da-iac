#!/bin/bash

gcloud artifacts repositories create ${DOCKER_REPOSITORY_NAME} \
    --project=${PROJECT_ID} \
    --repository-format="docker" \
    --location=${COMPUTE_REGION}