output "landing_zone_dataset" {
  value = google_bigquery_dataset.landing_zone_dataset.dataset_id
  description = "Name of bigquery landing zone dataset resources being provisioned."
}
output "curated_zone_dataset" {
  value = google_bigquery_dataset.curated_zone_dataset.dataset_id
  description = "Name of bigquery curated dataset resources being provisioned."
}
output "consumption_zone_dataset" {
  value = google_bigquery_dataset.consumption_zone_dataset.dataset_id
  description = "Name of bigquery consumption dataset resources being provisioned."
}

/*output "lz_customer_table" {
  value = google_bigquery_table.lz_customer_table.table_id
  description = "Name of landing zone bigquery table resources being provisioned."
}
output "cr_customer_table" {
  value = google_bigquery_table.cr_customer_table.table_id
  description = "Name of curated bigquery table resources being provisioned."
}

output "bigquery_lz_tables" {
  value       = module.bigquery_lz_tables.bigquery_tables
  description = "Map of bigquery table resources being provisioned."
}*/

#Add output variable for views