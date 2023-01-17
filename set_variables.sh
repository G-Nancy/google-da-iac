#!/bin/bash
#
# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# The Google Cloud project to use for this solution

#set up gcloud auth login for selective project
#gcloud config set project pso-erste-digital-sandbox
export PROJECT_ID='pso-erste-digital-sandbox' #"[YOUR_PROJECT_ID]"
# The Compute Engine region to use for running Dataflow jobs and create a temporary storage bucket
export COMPUTE_REGION='europe-west1'
export ACCOUNT='gnancy@google.com' #<current user account email>
export BUCKET_NAME=${PROJECT_ID}-'tf-state-erste' #<terraform state bucket>
export BUCKET='gs://'${BUCKET_NAME} #<terraform state bucket>
export TF_SA='setup-infra-tf' #<service account name used by terraform>
export CONFIG='erste-digital'

echo "terraform service account = ${TF_SA}"
echo "terraform gcs bucket = ${BUCKET}"
echo "projects COMPUTE_REGION = ${COMPUTE_REGION}"

#gcloud config configurations create $CONFIG
gcloud config set project $PROJECT_ID
gcloud config set account $ACCOUNT
gcloud config set compute/region $COMPUTE_REGION
#gcloud auth login
gcloud auth application-default login
#gsutil mb -p $PROJECT_ID -l $COMPUTE_REGION -b on $BUCKET

export VARS=dev.tfvars