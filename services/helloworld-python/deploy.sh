gcloud run deploy helloworld-python --source . \
--no-allow-unauthenticated \
--ingress="internal" \
--region=$REGION \
--service-account=${CUSTOMER_SCORING_SA_EMAIL} \
--set-env-vars="MIN_SCORE=0,MAX_SCORE=10"
