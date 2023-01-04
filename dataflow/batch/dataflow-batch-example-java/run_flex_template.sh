RUN_ID=`date +%Y%m%d-%H%M%S`
gcloud dataflow flex-template run "batch-example-flex-noip-${RUN_ID}" \
    --template-file-gcs-location "gs://pso-erste-digital-sandbox-dataflow/flex-templates/batch-example-java/batch-example-java-metadata.json" \
    --parameters inputTable="sandbox.customer" \
    --parameters outputTable="sandbox.customer_score" \
    --temp-location "gs://pso-erste-digital-sandbox-dataflow/runs/batch-example-java/${RUN_ID}/temp/" \
    --staging-location "gs://pso-erste-digital-sandbox-dataflow/runs/batch-example-java/${RUN_ID}/stg/" \
    --worker-machine-type "n2-standard-2" \
    --region "europe-west3" \
    --num-workers 1 \
    --disable-public-ips
#    --service-account-email "dataflow-temp@pso-erste-digital-sandbox.iam.gserviceaccount.com"

    #--network