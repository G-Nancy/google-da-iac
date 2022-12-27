# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset


######## Datasets ##############################################################

resource "google_bigquery_dataset" "landing_zone_dataset" {
  project = var.project
  location = var.region
  dataset_id = var.lz_dataset
  description = "To store landing zone data in BigQuery"
}

resource "google_bigquery_dataset" "curated_zone_dataset" {
  project = var.project
  location = var.region
  dataset_id = var.cr_dataset
  description = "To store curated layer data in BigQuery"
}

resource "google_bigquery_dataset" "consumption_zone_dataset" {
  project = var.project
  location = var.region
  dataset_id = var.cm_dataset
  description = "To store consumption layer data in BigQuery"
}

##### Tables #######################################################

resource "google_bigquery_table" "customer_table" {
  project = var.project
  dataset_id = google_bigquery_dataset.landing_zone_dataset.dataset_id
  table_id = "customers"

  time_partitioning {
    type = "DAY"
    #expiration_ms = 604800000 # 7 days
  }

  schema = file("modules/bigquery-core/schema/customer.json")
# deletion_protection = true
}