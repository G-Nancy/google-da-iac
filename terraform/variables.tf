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

variable "project" {
  type = string
}

variable "compute_region" {
  type = string
}

variable "data_region" {
  type = string
}
variable "terraform_service_account" {
  type = string
}

variable "bq_landing_dataset_name" {
  type = string
  default = "bq_landing"
}

variable "bq_curated_dataset_name" {
  type = string
  default = "bq_curated"
}

variable "bq_consumption_dataset_name" {
  type = string
  default = "bq_consumption"
}

variable "bq_lz_tables" {
  description = "A list of maps that includes table_id, schema, clustering, time_partitioning, range_partitioning, view, expiration_time, labels in each element."
  default     = []
  type = list(object({
    table_id   = string,
    schema     = string,
    clustering = list(string),
    time_partitioning = object({
      expiration_ms            = string,
      field                    = string,
      type                     = string,
      require_partition_filter = bool,
    }),
    range_partitioning = object({
      field = string,
      range = object({
        start    = string,
        end      = string,
        interval = string,
      }),
    }),
    expiration_time = string,
    labels          = map(string),
  }))
}

variable "bq_cr_tables" {
  description = "A list of maps that includes table_id, schema, clustering, time_partitioning, range_partitioning, view, expiration_time, labels in each element."
  default     = []
  type = list(object({
    table_id   = string,
    schema     = string,
    clustering = list(string),  # Specifies column names to use for data clustering. Up to four top-level columns are allowed, and should be specified in descending priority order. Partitioning should be configured in order to use clustering.
    time_partitioning = object({
      expiration_ms            = string, # The time when this table expires, in milliseconds since the epoch. If set to `null`, the table will persist indefinitely.
      field                    = string,
      type                     = string,
      require_partition_filter = bool,
    }),
    range_partitioning = object({
      field = string,
      range = object({
        start    = string,
        end      = string,
        interval = string,
      }),
    }),
    expiration_time = string,
    labels          = map(string),
  }))
}

variable "cm_views" {
  description = "A list of objects which include table_id, which is view id, and view query"
  default     = []
  type = list(object({
    view_id        = string,
    query          = string,
    table          = string,
    use_legacy_sql = bool,
    labels         = map(string),
  }))
}

variable "bq_bi_dataset" {
  description = "The attributes for creating BI team datasets"
  type = map(object({
    region = string,
    description = string,
    domain_reader = string,
    owner = string,
    labels = map(string)
  },))
  default = {}
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the instance will fail"
  type        = bool
  default     = false
}

############spanner variables###############
variable "spanner_instance" {
  type = string
}

variable "spanner_node_count" {
  type = number
}

variable "spanner_db_retention_days" {
  type = string
  default = "2d"
}

variable "spanner_labels" {
  description = "A mapping of labels to assign to the spanner instance."
  type        = map(string)
}


############composer variables###############
variable "zone" {
  type = string
  description = "The zone the resources will be created in"
}

variable "composer_service_account_name" {
  type = string
  description = "Name of Composer Environment"
  default = "composer-e-dev"
}

variable "composer_name" {
  type = string
  description = "Name of Composer Environment"
  default = "e-dev"
}

#variable "composer_master_ipv4_cidr_block" {
#  type = string
#  description = "The IP range in CIDR notation to use for the hosted master network (private cluster)"
#}

variable "network_name" {
  description = "The self_link of the VPC network to use"
}

variable "subnetwork_name" {
  description = "The self_link of the VPC subnetwork to use"
}

variable "composer_labels" {
  description = "A mapping of labels to assign to the spanner instance."
  type        = map(string)
}

##################Cloud storage Variables############
variable "gcs_e_bkt_list" {
  description = "The attributes for creating Cloud storage buckets"
  type = map(object({
    name = string,
    location = string,
    uniform_bucket_level_access = string
#    lifecycle_rule = map(object({
#      condition = any
#      action = any
#    }))
    labels = map(string)
  },))
  default = {}
}

################## Artifact Registry Variables############
variable "artifact_repo_labels" {
  description = "A mapping of labels to assign to the spanner instance."
  type        = map(string)
}

variable "artifact_repo_description" {
  description = "An optional description for the repository."
  type        = string
  default     = "Terraform-managed registry"
}

variable "artifact_repo_format" {
  description = "Repository format. One of DOCKER or UNSPECIFIED."
  type        = string
  default     = "DOCKER"
}

variable "artifact_repo_iam" {
  description = "IAM bindings in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
}

variable "artifact_repo_id" {
  description = "Repository id."
  type        = string
}

################## Dataflow Variables############
variable "df_project_permissions" {
  type = list
  default = [
    "roles/dataflow.admin",
    "roles/run.invoker", # to invoke cloud run
    "roles/bigquery.dataEditor", # to create tables and load data
    "roles/bigquery.jobUser", # to create bigquery load/query jobs
    "roles/artifactregistry.reader",
    "roles/dataflow.worker",
    "roles/storage.admin",
  ]
}

variable "df_sa_name" {
  type = string
}

variable "cr_sa_name" {
  type = string
}

# Data Catalog Variables
variable "activated_policy_types" {
  description = "A list of policy types that are activated for this taxonomy."
  type        = list(string)
  default     = []
}

#variable "domain_mapping" {
#  type = list(object({
#    project = string,
#    domain = string,
#    datasets = list(object({
#      name = string,
#      domain = string
#    })) // leave empty if no dataset overrides is required for this project
#  }))
#  description = "Mapping between domains and GCP projects or BQ Datasets. Dataset-level mapping will overwrite project-level mapping for a given project."
#}

variable "dc_tx_name" {
  type = string
  description = "the name for the taxonomy"
}

variable "tags" {
  description = "List of Data Catalog Policy tags to be created with optional IAM binging configuration in {tag => {ROLE => [MEMBERS]}} format."
  type        = map(map(list(string)))
  nullable    = false
  default     = {}
}

