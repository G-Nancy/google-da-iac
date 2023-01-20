#!/bin/bash


RAND=`date +%Y%m%d%H%M%S`
MESSAGE_DATA="{\"id\": ${RAND},\"firstName\": \"f-${RAND}\",\"lastName\": \"l-${RAND}\",\"dateOfBirth\": \"2000-01-01\",\"address\": \"a-${RAND}\"}"

echo ${MESSAGE_DATA}
gcloud pubsub topics publish $TOPIC_ID \
  --message="${MESSAGE_DATA}"