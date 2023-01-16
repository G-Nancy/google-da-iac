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
  alias = "impersonation"
  scopes = [
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

data "google_service_account_access_token" "default" {
  provider = google.impersonation
  target_service_account = var.terraform_service_account
  scopes = [
    "userinfo-email",
    "cloud-platform"]
  lifetime = "1200s"
}

provider "google" {
  project = var.project
  region = var.compute_region

  access_token = data.google_service_account_access_token.default.access_token
  request_timeout = "60s"
}

provider "google-beta" {
  project = var.project
  region = var.compute_region

  access_token = data.google_service_account_access_token.default.access_token
  request_timeout = "60s"
}

locals {
#  common_cloud_run_variables = [
#    {
#      name = "PROJECT_ID",
#      value = var.project,
#    },
#    {
#      name = "COMPUTE_REGION_ID",
#      value = var.compute_region,
#    },
#    {
#      name = "DATA_REGION_ID",
#      value = var.data_region,
#    }
#  ]
#
#  # Only projects with configured domains
#  domains = distinct([for entry in var.domain_mapping: entry if lookup(entry, "domain") != ""])
}

module "bigquery" {
  source = "./modules/bigquery-core"
  project = var.project
  region = var.data_region
  lz_dataset = var.bq_landing_dataset_name
  cr_dataset = var.bq_curated_dataset_name
  cm_dataset = var.bq_consumption_dataset_name
  lz_tables = var.bq_lz_tables
  cr_tables = var.bq_cr_tables
  cm_views = var.cm_views
  bq_bi_dataset = var.bq_bi_dataset
  deletion_protection = var.deletion_protection
}

module "spanner" {
  source = "./modules/spanner"
  project = var.project
  region = var.compute_region
  spanner_instance = var.spanner_instance
  spanner_node_count = var.spanner_node_count
  spanner_db_retention_days = var.spanner_db_retention_days
  spanner_labels = var.spanner_labels
}

module "composer" {
  source                          = "./modules/composer"
  composer_service_account_name   = var.composer_service_account_name
  composer_name                   = "composer-${var.composer_name}"
  project                         = var.project
  region                          = var.compute_region
  zone                            = var.zone
  orch_network                    = var.network_name
  orch_subnetwork                 = var.subnetwork_name
#  composer_master_ipv4_cidr_block = var.composer_master_ipv4_cidr_block
  composer_labels                 = var.composer_labels
}
module "gcs" {
  source = "./modules/gcs"
  gcs_e_bkt_list = var.gcs_e_bkt_list
}

#module "data-catalog" {
##  count = length(local.domains)
#  source = "./modules/data-catalog"
#  project = var.project
#  region = var.data_region
##  domain = local.domains[count.index]
##  activated_policy_types = var.activated_policy_types
#}


# BigQuery Core (it's module)
  # landing dataset
  # curated dataset
  # consumption dataset

  # One sample table with it's schema, with partition and clustering  (schema: customer_name, customer_birth_date)
  # The same sample table for the curated zone with extra metadata columns (schema: meta_data.source_system, customer_name, customer_birth_date)
  # sample 1:1 view in the consumption dataset with view definition in a template file

# BigQuery Consumption
  # A module that could be invoked N times depending on the number of consumers
  # We should have a list of Consumers (with their requied attributes) that we automate the creation of their reporting envs for
  # For now the module should create a reporting dataset with the consumer name and add a resource label to it (e.g. owner="team name")
  # Grant the team emails R/W access on the created dataset(s)
  # [{"team": "bla", "groups": ["bla@customer.com"]}, {"team": "xyz", "groups": ["xyz@customer.com"}]]

# Data Catalog
  # https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/data_catalog_tag_template
  # Tag template with sample business metadata fields. Maybe show case different types of fields (strings, lists/enums, etc)

# Composer
  # Create a cluster

# Spanner
  # Create an instance of Spanner
  # Sample schema

# IAM
  # Service account for dataflow
  # Service account for Composer
  # Access for these SAs (to BQ, GCS, Dataflow)
  # (Postpone for now) row level access on BigQuery