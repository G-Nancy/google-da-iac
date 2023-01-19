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
#


# Check README.md to export the variables needed by this script

gcloud auth configure-docker \
  ${COMPUTE_REGION}-docker.pkg.dev

FLEX_IMAGE=${COMPUTE_REGION}-docker.pkg.dev/${PROJECT_ID}/${DOCKER_REPOSITORY_NAME}/dataflow/${PIPELINE_NAME}/flex-template

echo "FLEX_IMAGE=${FLEX_IMAGE}"

# 0. Package the Maven project to create a JAR
mvn -f ${POM_PATH} clean package


# 1. Build and tag Flex-Template Image

docker build -t ${FLEX_IMAGE}:latest -f ${FLEX_DOCKER_PATH} .
docker tag ${FLEX_IMAGE}:latest ${FLEX_IMAGE}:${IMAGE_BUILD_VERSION}

# 2. Push Flex-Template Image
docker push ${FLEX_IMAGE}:${IMAGE_BUILD_VERSION}
docker push ${FLEX_IMAGE}:latest


# 3. Create Flex-Template JSON file
gcloud dataflow flex-template build ${FLEX_TEMPLATE_PATH} \
  --image-gcr-path "${FLEX_IMAGE}:${IMAGE_BUILD_VERSION}" \
  --sdk-language "JAVA" \
  --flex-template-base-image JAVA11 \
  --metadata-file ${FLEX_META_DATA_PATH} \
  --jar ${JAVA_JAR} \
  --env FLEX_TEMPLATE_JAVA_MAIN_CLASS=${JAVA_MAIN_CLASS}