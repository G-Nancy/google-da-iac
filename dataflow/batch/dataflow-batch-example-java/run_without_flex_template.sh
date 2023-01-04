RUN_ID=`date +%Y%m%d-%H%M%S`

mvn clean package

java -jar target/dataflow-batch-example-java-bundled-1.0.jar \
  --runner=DataflowRunner \
  --project=pso-erste-digital-sandbox \
  --region=europe-west3 \
  --tempLocation=gs://pso-erste-digital-sandbox-dataflow/runs/batch-example/${RUN_ID}/temp/ \
  --inputTable=sandbox.customer \
  --outputTable=sandbox.customer_score \
  --jobName="batch-example-${RUN_ID}" \
  --workerMachineType=n2-standard-2 \
  --numWorkers=1 \
  --serviceAccount=634617552237-compute@developer.gserviceaccount.com \
  --stagingLocation=gs://pso-erste-digital-sandbox-dataflow/runs/batch-exaample/${RUN_ID}/stg/




