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

output "landing_dataset_id" {
  value       = google_bigquery_dataset.landing_zone_dataset.dataset_id
}

output "curated_dataset_id" {
  value       = google_bigquery_dataset.curated_zone_dataset.dataset_id
}

output "consumption_dataset_id" {
  value       = google_bigquery_dataset.consumption_zone_dataset.dataset_id
}

output "landing_table_ids" {
  value = [
  for table in google_bigquery_table.landing_customer_table :
  table.table_id
  ]
  description = "Unique id for the table being provisioned"
}

output "curated_table_ids" {
  value = [
  for table in google_bigquery_table.curated_customer_table :
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
