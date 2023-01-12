# fail script on error
        #set -e


        REGION=europe-west3
        PROJECT=pso-erste-digital-sandbox
        DOCKER_REPO=dataplatform
        PIPELINE_NAME=batch-example-java
        FLEX_DOCKER_PATH=Dockerfile
        IMAGE_BUILD_VERSION=1.0
        FLEX_TEMPLATE_PATH=gs://pso-erste-digital-sandbox-dataflow/flex-templates/${PIPELINE_NAME}/${PIPELINE_NAME}-metadata.json

        gcloud auth configure-docker \
            ${REGION}-docker.pkg.dev

        FLEX_IMAGE=${REGION}-docker.pkg.dev/${PROJECT}/${DOCKER_REPO}/dataflow/${PIPELINE_NAME}/flex-template

        echo "FLEX_IMAGE=${FLEX_IMAGE}"

        # 0. Package the Maven project to create a JAR
        mvn clean package


        # 1. Build and tag Flex-Template Image

        docker build -t ${FLEX_IMAGE}:latest -f ${FLEX_DOCKER_PATH} .
        docker tag ${FLEX_IMAGE}:latest ${FLEX_IMAGE}:${IMAGE_BUILD_VERSION}

        # 2. Push Flex-Template Image
        docker push ${FLEX_IMAGE}:${IMAGE_BUILD_VERSION}
        docker push ${FLEX_IMAGE}:latest


        # 3. Create Flex-Template JSON file
        gcloud dataflow flex-template build ${FLEX_TEMPLATE_PATH} \
              --image-gcr-path "${FLEX_IMAGE}:latest" \
              --sdk-language "JAVA" \
              --flex-template-base-image JAVA11 \
              --metadata-file "metadata.json" \
              --jar "target/dataflow-batch-example-java-bundled-1.0.jar" \
              --env FLEX_TEMPLATE_JAVA_MAIN_CLASS="com.google.cloud.pso.BatchExamplePipeline"