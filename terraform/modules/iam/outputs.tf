output "sa_dataflow_runner_email" {
  value = google_service_account.sa_dataflow_runner.email
}

output "sa_cloudrun_email" {
  value = google_service_account.sa_cloudrun.email
}

output "sa_composer_email" {
  value = google_service_account.sa_composer.email
}