#!/bin/bash

# Copy schema file to create tables
gsutil -m cp terraform/modules/bigquery-core/schema/landing/customer_stg.json gs://${DATA_BUCKET_CUSTOMERS}/schema/customer_stg.json

# Copy  SQL files
gsutil -m cp composer/sql/*.sql gs://${COMPOSER_BUCKET_NAME}/data/sql/

# Copy python dags and helpers
gsutil cp composer/dags/*.py gs://${COMPOSER_BUCKET_NAME}/dags/
