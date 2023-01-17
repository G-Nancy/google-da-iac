#output "landing_zone_dataset" {
#  value = google_bigquery_dataset.landing_zone_dataset.dataset_id
#  description = "Name of bigquery landing zone dataset resources being provisioned."
#}
#output "curated_zone_dataset" {
#  value = google_bigquery_dataset.curated_zone_dataset.dataset_id
#  description = "Name of bigquery curated dataset resources being provisioned."
#}
#output "consumption_zone_dataset" {
#  value = google_bigquery_dataset.consumption_zone_dataset.dataset_id
#  description = "Name of bigquery consumption dataset resources being provisioned."
#}

output "bigquery_lz_dataset" {
  value       = google_bigquery_dataset.landing_zone_dataset
  description = "Bigquery dataset resource."
}

output "bigquery_cr_dataset" {
  value       = google_bigquery_dataset.curated_zone_dataset
  description = "Bigquery dataset resource."
}

output "bigquery_cm_dataset" {
  value       = google_bigquery_dataset.consumption_zone_dataset
  description = "Bigquery dataset resource."
}

output "lz_table_ids" {
  value = [
  for table in google_bigquery_table.lz_customer_table :
  table.table_id
  ]
  description = "Unique id for the table being provisioned"
}

output "cr_table_ids" {
  value = [
  for table in google_bigquery_table.cr_customer_table :
  table.table_id
  ]
  description = "Unique id for the table being provisioned"
}

output "view_cr_ids" {
  value = [
  for view in google_bigquery_table.view_cr_layer :
  view.table_id
  ]
  description = "Unique id for the view being provisioned"
}
