#!/bin/bash




# TODO: these should be a param to the script
COMPOSER_ENV=composer-1
LAST_VERSION=1.0
VARIABLES_FILE_PATH=variables/poc/variables.txt
REGION=europe-west3

# substitute the latest build version palceholder in the variables file. This approach is a demo for dynamic variables
# that are created by another process (e.g. run id of the CICD pipeline used to tag container images)
VAR_FILE=/tmp/composer_vars.txt
perl -pe "s~&LAST_VERSION&~$LAST_VERSION~g" $VARIABLES_FILE_PATH > ${VAR_FILE}

# concat variables from file using '-sd,'
# remove white spaces with 'sed'
VARIABLES=$(paste -sd, ${VAR_FILE} | sed 's/ //g')

echo "Variables string is ${VARIABLES}"

CMD="gcloud composer environments update ${COMPOSER_ENV} \
        --location ${REGION} \
        --update-env-variables=${VARIABLES} \
        2>&1 1>/dev/null"

echo "Command to excute is ${CMD}"

ERROR=$(eval $CMD)

EXIT_CODE=0

if [[ $ERROR == *"No change in configuration"* ]]; then
  echo "No change in configuration detected."
  EXIT_CODE=0
elif [[ $ERROR == *"done." ]]; then
  echo "Command executed successfully."
  EXIT_CODE=0
elif [[ -z "$ERROR" ]]; then
  echo "Command executed successfully."
  EXIT_CODE=0
else
  echo "Error detected while executing command: ${ERROR}"
  EXIT_CODE=1
fi

exit $EXIT_CODE