output "composer_airflow_uri" {
  description = "The URI of the Apache Airflow Web UI hosted within the Cloud Composer environment.."
  value       = google_composer_environment.main.config[0].airflow_uri
}

output "composer_dag_gcs" {
  description = "The Cloud Storage prefix of the DAGs for the Cloud Composer environment."
  value       = google_composer_environment.main.config[0].dag_gcs_prefix
}