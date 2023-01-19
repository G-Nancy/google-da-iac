#### Required buckets by the platform ########

resource "google_storage_bucket" "dataflow_bucket" {
  project = var.project
  name          = "${var.project}-${var.dataflow_bucket_name_suffix}"
  # This bucket is used by the services so let's create in the same compute region
  location      = var.compute_region

  # force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    created_by: "terraform"
  }
}

#### Optional buckets ############

resource "google_storage_bucket" "create_bucket" {
  for_each = var.gcs_buckets
  name = "${var.project}-${each.key}"
  location = var.data_region
  uniform_bucket_level_access = each.value["uniform_bucket_level_access"]
  labels = each.value["labels"]
}