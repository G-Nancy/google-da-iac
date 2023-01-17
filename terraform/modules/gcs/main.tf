resource "google_storage_bucket" "create_bucket" {
  for_each = var.gcs_e_bkt_list
  name = each.key
  location = each.value["location"]
  uniform_bucket_level_access = each.value["uniform_bucket_level_access"]
  labels = each.value["labels"]
}