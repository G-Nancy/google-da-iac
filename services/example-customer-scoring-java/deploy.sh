#!/bin/bash
#
# Copyright 2022 Google LLC
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

mvn install

#mvn compile jib:build -Dimage="${REGION}-docker.pkg.dev/${PROJECT}/${DOCKER_REPO}/services/example-customer-scoring-java:latest"
mvn compile jib:build -Dimage="${CUSTOMER_SCORING_IMAGE}"

gcloud run deploy example-customer-scoring-java \
--image=${CUSTOMER_SCORING_IMAGE} \
--region=${REGION} \
--service-account=${CUSTOMER_SCORING_SA_EMAIL} \
--set-env-vars="MIN_SCORE=0,MAX_SCORE=10" \
--allow-unauthenticated
#--no-allow-unauthenticated \
#--ingress="internal"

