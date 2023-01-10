#!/bin/bash

COMPOSER_BUCKET_NAME=europe-west3-composer-1-a08e7190-bucket

# Copy schema file to create tables
gsutil -m cp schema/customer_stg.json gs://pso-erste-digital-sandbox-data/customers/schema/customer_stg.json

# Copy  SQL files
gsutil -m cp sql/*.sql gs://${COMPOSER_BUCKET_NAME}/data/sql/

# Copy python dags and helpers
gsutil cp dags/*.py gs://${COMPOSER_BUCKET_NAME}/dags/
