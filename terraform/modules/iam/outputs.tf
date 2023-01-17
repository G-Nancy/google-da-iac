output "sa_dataflow_runner" {
  value = google_service_account.sa_dataflow_runner.email
}

output "sa_cloudrun" {
  value = google_service_account.sa_cloudrun.email
}

output "composer_sa_email" {
  value = google_service_account.composer_sa_email.email
}