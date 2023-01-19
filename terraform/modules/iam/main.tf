
locals {
  dataflow_sa_project_permissions = [
    "roles/dataflow.admin",
    "roles/run.invoker", # to invoke cloud run
    "roles/bigquery.dataEditor", # to create tables and load data
    "roles/bigquery.jobUser", # to create bigquery load/query jobs
    "roles/artifactregistry.reader",
    "roles/dataflow.worker",
    "roles/storage.admin"]

  composer_sa_project_permissions = [
    "roles/composer.admin",
    "roles/composer.worker",
    "roles/composer.environmentAndStorageObjectAdmin",
    "roles/bigquery.dataEditor",
    "roles/bigquery.jobUser",
    "roles/dataflow.admin",
    "roles/iam.serviceAccountUser"
  ]
}

// Provision a service account that will be bound to the Dataflow pipeline
resource "google_service_account" "sa_dataflow_runner" {
  account_id   = var.dataflow_sa_name
  display_name = "${var.dataflow_sa_name}-dataflow-runner"
  description  = "The service account bound to the compute engine instance provisioned to run Dataflow Jobs"
}

// Provision IAM roles for the Dataflow runner service account
resource "google_project_iam_member" "dataflow_runner_service_account_roles" {
  for_each = toset(local.dataflow_sa_project_permissions)
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
  account_id   = var.cloudrun_sa_name
  display_name = "${var.cloudrun_sa_name}-cloud-run"
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

resource "google_service_account" "sa_composer" {
  account_id   = var.composer_sa_name
  display_name = "Service Account for Composer Environment"
  project      = var.project
}

// Provision IAM roles for the Composer service account
resource "google_project_iam_member" "composer_service_account_roles" {
  for_each = toset(local.composer_sa_project_permissions)
  role    = each.key
  member  = "serviceAccount:${google_service_account.sa_composer.email}"
  project = var.project
}