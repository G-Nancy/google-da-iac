# /******************************************
#   Create composer service account and permissions
#  *****************************************/

resource "google_service_account" "composer_sa_email" {
  account_id   = var.composer_service_account_name
  display_name = "Service Account for Composer Environment"
  project      = var.project
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

##################to be removed############
#resource "google_project_iam_custom_role" "worker_custom_role" {
#  count       = var.enable ? 1 : 0
#  role_id     = "composer.WorkerCustom"
#  title       = "Composer worker custom role"
#  description = "A role added to the composer workers"
#  permissions = ["runtimeconfig.variables.get", "runtimeconfig.variables.list", "runtimeconfig.configs.get"]
#  project     = var.project
#}
#
#resource "google_project_iam_member" "composer_environment_custom_role" {
#  count      = var.enable ? 1 : 0
#  role       = google_project_iam_custom_role.worker_custom_role.id
#  member     = "serviceAccount:${google_service_account.composer_sa_email.email}"
#  project    = var.project
#  depends_on = ["google_project_iam_custom_role.worker_custom_role"]
#}
#############################

/******************************************
  Create Composer environment
 *****************************************/
resource "google_composer_environment" "main" {
#  provider = "google-beta"
  name     = var.composer_name
  region   = var.region
  project  = var.project
  labels   = var.composer_labels

  config {
    node_count = var.composer_node_count

    node_config {
      zone            = var.zone
      machine_type    = var.composer_machine_type
      disk_size_gb    = var.composer_node_storage_gb
#      network         = var.orch_network
#      subnetwork      = var.orch_subnetwork
      service_account = google_service_account.composer_sa_email.name
      tags            = ["composer"]

#      ip_allocation_policy {
#        use_ip_aliases                = true
#        services_secondary_range_name = "composer-services"
#        cluster_secondary_range_name  = "composer-pods"
#      }
    }

    # private_environment_config {
    #   enable_private_endpoint = true
    #   master_ipv4_cidr_block  = var.composer_master_ipv4_cidr_block
    # }

    software_config {
      image_version  = var.composer_image_version
      python_version = var.composer_python_version
      pypi_packages  = var.composer_pypi_packages
    }
  }

}