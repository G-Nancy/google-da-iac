RUN_ID=`date +%Y%m%d-%H%M%S`

export DATAFLOW_BUCKET=<dataflow resourses bucket created by terraform>
export JOB_PARAM_INPUT_TABLE=<dataset.table>
export JOB_PARAM_OUTPUT_TABLE=<dataset.table>
export JOB_PARAM_ERROR_TABLE=<dataset.table>
export JOB_PARAM_SERVICE_URL=<customer scoring service deployed by Terraform>
export JOB_WORKER_TYPE=n2-standard-2
export JOB_WORKERS_COUNT=1
export DATAFLOW_SERVICE_ACCOUNT_EMAIL=<dataflow sa deployed by Terraform>

mvn clean package

java -jar target/dataflow-batch-example-java-bundled-1.0.jar \
  --runner=DataflowRunner \
  --project=${PROJECT} \
  --region=${REGION} \
  --tempLocation=gs://${DATAFLOW_BUCKET}/runs/batch-example/${RUN_ID}/temp/ \
  --stagingLocation=gs://{DATAFLOW_BUCKET}/runs/batch-exaample/${RUN_ID}/stg/ \
  --inputTable=${JOB_PARAM_INPUT_TABLE}  \
  --outputTable=${JOB_PARAM_OUTPUT_TABLE}  \
  --errorTable=${JOB_PARAM_ERROR_TABLE} \
  --customerScoringServiceUrl=${JOB_PARAM_SERVICE_URL} \
  --jobName="batch-example-${RUN_ID}" \
  --workerMachineType=${JOB_WORKER_TYPE} \
  --numWorkers=${JOB_WORKERS_COUNT} \
  --serviceAccount=${DATAFLOW_SERVICE_ACCOUNT_EMAIL}




