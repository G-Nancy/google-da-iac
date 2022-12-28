project        = "pso-erste-digital-sandbox"
compute_region = "europe-west1"
data_region    = "eu"
bq_landing_dataset_name = "erste_bq_landing"
bq_curated_dataset_name = "erste_bq_curated"
bq_consumption_dataset_name = "erste_bq_consumption"

terraform_service_account = "setup-infra-tf@pso-erste-digital-sandbox.iam.gserviceaccount.com"

view_dataset_labels = {
  env      = "dev"
  billable = "true"
  owner    = "e-digital"
}
lz_dataset_labels = {
  env      = "dev"
  billable = "true"
  owner    = "e-digital"
}

bq_lz_tables = [
  {
    table_id           = "lz_customers",
    schema             = "modules/bigquery-core/schema/lz_customer.json",
    time_partitioning  = null,
    range_partitioning = null,
    expiration_time    = 2524604400000, # 2050/01/01
    clustering         = ["country"],
    labels = {
      env      = "devops"
      billable = "true"
      owner    = "e-lz"
    },
  }
]