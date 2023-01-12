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
#resource "google_bigquery_table" "bigquery_lz_tables" {
#  dataset_id                 = google_bigquery_dataset.landing_zone_dataset.dataset_id
#  description                = "tables in landing zone"
#  project                 = var.project
#  location                   = "EU"
#  tables                     = var.lz_tables
#  dataset_labels             = var.table_dataset_labels
#}


resource "google_bigquery_table" "lz_customer_table" {
  project = var.project
  dataset_id = google_bigquery_dataset.landing_zone_dataset.dataset_id
  table_id = "lz_customers"
  schema = file("modules/bigquery-core/schema/lz_customer.json")
  time_partitioning {
    type                     = "DAY"
    field                    = null      # The field used to determine how to create a time-based partition. If time-based partitioning is enabled without this value, the table is partitioned based on the load time. Set it to `null` to omit configuration.
    require_partition_filter = false     # If set to true, queries over this table require a partition filter that can be used for partition elimination to be specified. Set it to `null` to omit configuration.
    expiration_ms            = null      # Number of milliseconds for which to keep the storage for a partition.
  }
# deletion_protection = true
  clustering = ["country"]                    # Specifies column names to use for data clustering. Up to four top-level columns are allowed, and should be specified in descending priority order. Partitioning should be configured in order to use clustering.
  expiration_time = null             # The time when this table expires, in milliseconds since the epoch. If set to `null`, the table will persist indefinitely.
  labels = {                                  # A mapping of labels to assign to the table.
    env      = "dev"
    billable = "true"
  }
}

resource "google_bigquery_table" "cr_customer_table" {
  project = var.project
  dataset_id = google_bigquery_dataset.curated_zone_dataset.dataset_id
  table_id = "cr_customers"

  time_partitioning  {
    type                     = "DAY"
    field                    = null      # The field used to determine how to create a time-based partition. If time-based partitioning is enabled without this value, the table is partitioned based on the load time. Set it to `null` to omit configuration.
    require_partition_filter = false     # If set to true, queries over this table require a partition filter that can be used for partition elimination to be specified. Set it to `null` to omit configuration.
    expiration_ms            = null      # Number of milliseconds for which to keep the storage for a partition.
  }

  schema = file("modules/bigquery-core/schema/cr_customer.json")

  # deletion_protection = true
  clustering = ["country"]                    # Specifies column names to use for data clustering. Up to four top-level columns are allowed, and should be specified in descending priority order. Partitioning should be configured in order to use clustering.
  expiration_time = null             # The time when this table expires, in milliseconds since the epoch. If set to `null`, the table will persist indefinitely.
  labels = {                                  # A mapping of labels to assign to the table.
    env      = "dev"
    billable = "true"
  }
}


### Consumption Views ##################################################
resource "google_bigquery_table" "view_consumption_customer" {
  dataset_id = google_bigquery_dataset.consumption_zone_dataset.dataset_id
  table_id = "v_cn_customer"

  deletion_protection = false

  view {
    use_legacy_sql = false
    query = templatefile("modules/bigquery-core/views/v_cn_customer.tpl",
      {
        project = var.project
        dataset = var.cr_dataset
        cr_table = google_bigquery_table.cr_customer_table.table_id
      }
    )
  }
}

#####Team specific datasets#########################
resource "google_bigquery_dataset" "bi_dataset" {
  for_each = var.bq_bi_dataset
  project = var.project
  dataset_id = each.key
  location = each.value["region"]
  description = each.value["description"]
  labels = each.value["labels"]
  access {
    role          = "OWNER"
    user_by_email = each.value["owner"]
  }

  access {
    role   = "READER"
    domain = each.value["domain_reader"]
  }
}
