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
      zone = var.zone
      machine_type    = var.composer_machine_type
      disk_size_gb    = var.composer_node_storage_gb
#      network         = var.orch_network
#      subnetwork      = var.orch_subnetwork
      service_account = var.composer_service_account_email #google_service_account.composer_sa_email.name
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

      env_variables = var.env_variables
    }
  }
}