# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_table
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset

######## Datasets ##############################################################

resource "google_bigquery_dataset" "landing_zone_dataset" {
  project = var.project
  location = var.region
  dataset_id = var.landing_dataset
  description = "To store landing zone data in BigQuery"
}

resource "google_bigquery_dataset" "curated_zone_dataset" {
  project = var.project
  location = var.region
  dataset_id = var.curated_dataset
  description = "To store curated layer data in BigQuery"
}

resource "google_bigquery_dataset" "consumption_zone_dataset" {
  project = var.project
  location = var.region
  dataset_id = var.consumption_dataset
  description = "To store consumption layer data in BigQuery"
}

##### Tables #######################################################

resource "google_bigquery_table" "landing_customer_table" {
  project = var.project
  dataset_id = google_bigquery_dataset.landing_zone_dataset.dataset_id
  for_each = { for table in var.landing_tables : table["table_id"] => table }
  table_id = each.key
  labels              = each.value["labels"]
  schema              = file("${path.module}${each.value["schema"]}")
  clustering          = each.value["clustering"]
  expiration_time     = each.value["expiration_time"]
  deletion_protection = var.deletion_protection

  dynamic "time_partitioning" {
    for_each = each.value["time_partitioning"] != null ? [each.value["time_partitioning"]] : []
    content {
      type                     = time_partitioning.value["type"]
      expiration_ms            = time_partitioning.value["expiration_ms"]
      field                    = time_partitioning.value["field"]
      require_partition_filter = time_partitioning.value["require_partition_filter"]
    }
  }
}

resource "google_bigquery_table" "curated_customer_table" {
  project = var.project
  dataset_id = google_bigquery_dataset.curated_zone_dataset.dataset_id
#  table_id = "cr_customers"
#  schema = file("modules/bigquery-core/schema/cr_customer.json")
  for_each = { for table in var.curated_tables : table["table_id"] => table }
  table_id = each.key
  labels              = each.value["labels"]
  schema              = file("${path.module}${each.value["schema"]}")
  clustering          = each.value["clustering"]
  expiration_time     = each.value["expiration_time"]
  deletion_protection = var.deletion_protection

  dynamic "time_partitioning" {
    for_each = each.value["time_partitioning"] != null ? [each.value["time_partitioning"]] : []
    content {
      type                     = time_partitioning.value["type"]
      expiration_ms            = time_partitioning.value["expiration_ms"]
      field                    = time_partitioning.value["field"]
      require_partition_filter = time_partitioning.value["require_partition_filter"]
    }
  }
}

### Consumption Views ##################################################
resource "google_bigquery_table" "view_cr_layer" {
  for_each            = { for view in var.consumption_views : view["view_id"] => view }
  dataset_id          = google_bigquery_dataset.consumption_zone_dataset.dataset_id
  friendly_name       = each.key
  table_id            = each.value["table"]
  labels              = each.value["labels"]
  project             = var.project
  deletion_protection = var.deletion_protection
  view {
    query          = templatefile(each.value["query"],
    {
      project = var.project
      dataset = google_bigquery_dataset.curated_zone_dataset.dataset_id
      cr_table = each.value["table"]
    })
    use_legacy_sql = each.value["use_legacy_sql"]
  }

  lifecycle {
    ignore_changes = [
      encryption_configuration # managed by google_bigquery_dataset.main.default_encryption_configuration
    ]
  }
}


#####Team specific datasets#########################
resource "google_bigquery_dataset" "bi_datasets" {
  for_each = var.bq_consumers_datasets
  project = var.project
  dataset_id = each.key
  location = var.region
  description = each.value["description"]
  labels = each.value["labels"]

  dynamic access {
    for_each = each.value["iam_owners"]
    content {
      role          = "OWNER"
      user_by_email = access.value
    }
  }
}
