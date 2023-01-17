// Provision a service account that will be bound to the Dataflow pipeline
resource "google_service_account" "sa_dataflow_runner" {
  account_id   = var.df_sa_name
  display_name = "${var.df_sa_name}-dataflow-runner"
  description  = "The service account bound to the compute engine instance provisioned to run Dataflow Jobs"
}

// Provision IAM roles for the Dataflow runner service account
resource "google_project_iam_member" "dataflow_runner_service_account_roles" {
  for_each = toset(var.df_project_permissions)
  role    = each.key
  member  = "serviceAccount:${google_service_account.sa_dataflow_runner.email}"
  project = var.project
}

data "google_project" "project" {
}

resource "google_service_account_iam_binding" "df-account-iam" {
  service_account_id = google_service_account.sa_dataflow_runner.name
  for_each = toset(["roles/iam.serviceAccountUser","roles/iam.serviceAccountTokenCreator"])
  role = each.key
  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
    "serviceAccount:service-${data.google_project.project.number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
  ]
}

// Provision a service account for Cloud Run - Example Customer Scoring Service
resource "google_service_account" "sa_cloudrun" {
  account_id   = var.cr_sa_name
  display_name = "${var.cr_sa_name}-cloud-run"
  description  = "The service account bound to the cloud run to run customer scoring Jobs"
}

resource "google_service_account_iam_binding" "cr-account-iam" {
  service_account_id = google_service_account.sa_cloudrun.name
  for_each = toset(["roles/iam.serviceAccountUser","roles/iam.serviceAccountTokenCreator"])
  role = each.key
  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}

# /******************************************
#   Create composer service account and permissions
#  *****************************************/

resource "google_service_account" "composer_sa_email" {
  account_id   = var.composer_service_account_name
  display_name = "Service Account for Composer Environment"
  project      = var.project
}

resource "google_project_iam_member" "composer_admin" {
  role    = "roles/composer.admin"
  member  = "serviceAccount:${google_service_account.composer_sa_email.email}"
  project = var.project
}

resource "google_project_iam_member" "composer_worker" {
  role    = "roles/composer.worker"
  member  = "serviceAccount:${google_service_account.composer_sa_email.email}"
  project = var.project
}

resource "google_project_iam_member" "composer_environment_storage_admin" {
  role    = "roles/composer.environmentAndStorageObjectAdmin"
  member  = "serviceAccount:${google_service_account.composer_sa_email.email}"
  project = var.project
}

resource "google_project_iam_member" "composer_bigquery_data_editor" {
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.composer_sa_email.email}"
  project = var.project
}

resource "google_project_iam_member" "composer_bigquery_job_user" {
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.composer_sa_email.email}"
  project = var.project
}

resource "google_project_iam_member" "composer_dataflow_admin" {
  role    = "roles/dataflow.admin"
  member  = "serviceAccount:${google_service_account.composer_sa_email.email}"
  project = var.project
}

resource "google_project_iam_member" "composer_iam_service_account_user" {
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.composer_sa_email.email}"
  project = var.project
}