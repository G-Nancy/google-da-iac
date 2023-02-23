#   Copyright 2021 Google LLC
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.



provider "google" {
  alias  = "impersonation"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

data "google_service_account_access_token" "default" {
  provider               = google.impersonation
  target_service_account = var.terraform_service_account
  scopes                 = [
    "userinfo-email",
    "cloud-platform"
  ]
  lifetime = "1200s"
}

provider "google" {
  project = var.project
  region  = var.compute_region

  access_token    = data.google_service_account_access_token.default.access_token
  request_timeout = "60s"
}

provider "google-beta" {
  project = var.project
  region  = var.compute_region

  access_token    = data.google_service_account_access_token.default.access_token
  request_timeout = "60s"
}

module "bigquery" {
  source                = "./modules/bigquery-core"
  project               = var.project
  region                = var.data_region
  landing_dataset       = var.bq_landing_dataset_name
  curated_dataset       = var.bq_curated_dataset_name
  consumption_dataset   = var.bq_consumption_dataset_name
  landing_tables        = var.bq_landing_tables
  curated_tables        = var.bq_curated_tables
  consumption_views     = var.bq_consumption_views
  bq_consumers_datasets = var.bq_consumers_datasets
  deletion_protection   = var.deletion_protection
}

# TODO: uncomment this if you want to deploy a Spanner instance. However, note that it can incur significant cost if left unused
#module "spanner" {
#  source                    = "./modules/spanner"
#  project                   = var.project
#  region                    = var.compute_region
#  spanner_instance          = var.spanner_instance_name
#  spanner_node_count        = var.spanner_node_count
#  spanner_db_retention_days = var.spanner_db_retention_days
#  spanner_labels            = var.spanner_labels
#}

module "composer" {
  source                         = "./modules/composer"
  composer_service_account_email = module.iam.sa_composer_email
  composer_name                  = var.composer_name
  project                        = var.project
  region                         = var.compute_region
  zone                           = var.compute_zone
  orch_network                   = var.network_name
  orch_subnetwork                = var.subnetwork_name
  #  composer_master_ipv4_cidr_block = var.composer_master_ipv4_cidr_block
  composer_labels                = var.composer_labels
  env_variables                  = {
    env                                  = var.environment_level
    project                              = var.project
    customer_dataflow_flex_template_spec = var.customer_dataflow_flex_template_spec
    dataflow_temp_bucket                 = module.gcs.dataflow_bucket_name
    dataflow_service_account_email       = module.iam.sa_dataflow_runner_email
    bq_curated_dataset                   = module.bigquery.curated_dataset_id
    bq_landing_dataset                   = module.bigquery.landing_dataset_id
    compute_region                       = var.compute_region
    compute_zone                         = var.compute_zone
    last_version                         = var.deployment_version
    customer_scoring_url                 = "${module.cloud-run-customer-scoring.service_endpoint}/api/customer/score"
  }
}

module "gcs" {
  source                      = "./modules/gcs"
  gcs_buckets                 = var.gcs_buckets
  dataflow_bucket_name_suffix = var.dataflow_bucket_name_suffix
  project                     = var.project
  compute_region              = var.compute_region
  data_region                 = var.data_region
}

module "docker_artifact_registry" {
  source   = "./modules/artifact-registry"
  project  = var.project
  location = var.compute_region

  repository_id = var.artifact_repo_name
  iam           = var.artifact_repo_iam
}

module "iam" {
  source           = "./modules/iam"
  project          = var.project
  dataflow_sa_name = var.dataflow_sa_name #Dataflow service account
  cloudrun_sa_name = var.cloudrun_sa_name #Cloud Run service account
  composer_sa_name = var.composer_sa_name #Composer service account
}

module "data-catalog" {
  source                 = "./modules/data-catalog"
  name                   = var.data_catalog_taxonomy_name
  project                = var.project
  region                 = var.data_region
  activated_policy_types = var.data_catalog_activated_policy_types
  tags                   = var.data_catalog_taxonomy_tags
}


module "cloud-run-customer-scoring" {
  source                         = "./modules/cloud-run"
  project                        = var.project
  region                         = var.compute_region
  service_image                  = var.customer_scoring_service_image
  service_name                   = "customer-scoring-java"
  service_account_email          = module.iam.sa_cloudrun_email
  invoker_service_account_emails = [module.iam.sa_dataflow_runner_email]
  timeout_seconds                = var.cloud_run_timeout_seconds
  max_cpu                        = 1

  # Use the common variables in addition to specific variables for this service
  environment_variables = [
    {
      name  = "MIN_SCORE",
      value = "0",
    },
    {
      name  = "MAX_SCORE",
      value = "10",
    }
  ]
}

module "pubsub" {
  source                             = "./modules/pubsub"
  project                            = var.project
  customer_data_topic_name           = "customer-topic"
  customer_data_subscription_name    = "customer-pull-sub"
  customer_data_subscription_readers = [module.iam.sa_dataflow_runner_email]
}