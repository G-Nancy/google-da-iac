  FROM gcr.io/dataflow-templates-base/java11-template-launcher-base

  ARG WORKDIR=/dataflow/template
  RUN mkdir -p ${WORKDIR}
  RUN mkdir -p ${WORKDIR}/src/main/java/com/google/cloud/pso
  WORKDIR ${WORKDIR}

  COPY . /flex-template
  WORKDIR /flex-template

  ENV FLEX_TEMPLATE_JAVA_MAIN_CLASS="com.google.cloud.pso.BatchExamplePipeline"
  ENV FLEX_TEMPLATE_JAVA_CLASSPATH="flex-template/src/main/java/com/google/cloud/pso/BatchExamplePipeline.java"

  ENTRYPOINT ["/opt/google/dataflow/java_template_launcher"]