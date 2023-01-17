output "tags" {
  description = "Policy Tags."
  value       = { for k, v in google_data_catalog_policy_tag.default_tags : k => v.id }
}

output "taxonomy_id" {
  description = "Taxonomy id."
  value       = google_data_catalog_taxonomy.default_taxonomy.id
}