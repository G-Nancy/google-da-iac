RUN_ID=`date +%Y%m%d-%H%M%S`

mvn clean package

java -jar target/dataflow-batch-example-java-bundled-1.0.jar \
  --runner=DataflowRunner \
  --project=pso-erste-digital-sandbox \
  --region=europe-west3 \
  --tempLocation=gs://pso-erste-digital-sandbox-dataflow/runs/batch-example/${RUN_ID}/temp/ \
  --inputTable="erste_bq_curated.customer"  \
  --outputTable="erste_bq_curated.customer_score"  \
  --errorTable="erste_bq_curated.failed_customer_processing" \
  --customerScoringServiceUrl="https://example-customer-scoring-java-kiwdmfjrka-ey.a.run.app/api/customer/score" \
  --jobName="batch-example-${RUN_ID}" \
  --workerMachineType=n2-standard-2 \
  --numWorkers=1 \
  --serviceAccount="dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com" \
  --stagingLocation=gs://pso-erste-digital-sandbox-dataflow/runs/batch-exaample/${RUN_ID}/stg/




