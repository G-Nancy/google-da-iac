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

variable "deployment_version" {
  type    = string
  default = "1.0"
}

variable "project" {
  type = string
}

variable "environment_level" {
  type        = string
  description = "poc|dev|int|prd"
}

variable "compute_region" {
  type = string
}

variable "compute_zone" {
  type = string
}

variable "data_region" {
  type = string
}

variable "terraform_service_account" {
  type = string
}

variable "bq_landing_dataset_name" {
  type    = string
  default = "landing"
}

variable "bq_curated_dataset_name" {
  type    = string
  default = "curated"
}

variable "bq_consumption_dataset_name" {
  type    = string
  default = "consumption"
}

variable "bq_landing_tables" {
  description = "A list of maps that includes table_id, schema, clustering, time_partitioning, range_partitioning, view, expiration_time, labels in each element."

  type = list(object({
    table_id          = string,
    schema            = string,
    clustering        = list(string),
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

  default = [
    {
      table_id           = "customer_stg",
      schema             = "/schema/landing/customer_stg.json",
      time_partitioning  = null,
      range_partitioning = null,
      expiration_time    = 2524604400000, # 2050/01/01
      clustering         = [],
      labels             = {
        created_by = "terraform"
      },
    }
  ]
}

variable "bq_curated_tables" {
  description = "A list of maps that includes table_id, schema, clustering, time_partitioning, range_partitioning, view, expiration_time, labels in each element."

  type = list(object({
    table_id          = string,
    schema            = string,
    clustering        = list(string),
    # Specifies column names to use for data clustering. Up to four top-level columns are allowed, and should be specified in descending priority order. Partitioning should be configured in order to use clustering.
    time_partitioning = object({
      expiration_ms            = string,
      # The time when this table expires, in milliseconds since the epoch. If set to `null`, the table will persist indefinitely.
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

  default = [
    {
      table_id           = "customer",
      schema             = "/schema/curated/customer.json",
      time_partitioning  = null,
      range_partitioning = null,
      expiration_time    = 2524604400000, # 2050/01/01
      clustering         = [],
      labels             = {
        created_by = "terraform"
      },
    },
    {
      table_id           = "customer_score",
      schema             = "/schema/curated/customer_score.json",
      time_partitioning  = null,
      range_partitioning = null,
      expiration_time    = 2524604400000, # 2050/01/01
      clustering         = [],
      labels             = {
        created_by = "terraform"
      },
    },
    {
      table_id           = "failed_customer_processing",
      schema             = "/schema/curated/failed_record_processing.json",
      time_partitioning  = null,
      range_partitioning = null,
      expiration_time    = 2524604400000, # 2050/01/01
      clustering         = [],
      labels             = {
        created_by = "terraform"
      },
    }
  ]
}

variable "bq_consumption_views" {
  description = "A list of objects which include table_id, which is view id, and view query"
  type        = list(object({
    view_id        = string,
    query          = string,
    table          = string,
    use_legacy_sql = bool,
    labels         = map(string),
  }))

  default = [
    {
      view_id        = "v_customer",
      use_legacy_sql = false,
      table          = "customer"
      query          = "modules/bigquery-core/views/v_cn_customer.tpl"
      labels         = {
        created_by = "terraform"
      },
    },
    {
      view_id        = "v_customer_score",
      use_legacy_sql = false,
      table          = "customer_score"
      query          = "modules/bigquery-core/views/v_cn_customer_score.tpl"
      labels         = {
        created_by = "terraform"
      },
    }
  ]
}

variable "bq_consumers_datasets" {
  description = "Datasets for data consumer teams"
  type        = map(object({
    description = string,
    iam_owners  = list(string),
    labels      = map(string)
  }, ))
  default = {
    team1_dataset = {
      labels = {
        owner = "team1"
        created_by = "terraform"
      }
      description = "Team 1 specific dataset"
      iam_owners   = []
      description = "Team 1 specific dataset"
    }
    bq_team2_dataset = {
      labels = {
        owner = "team2" #Only lowercase char
        created_by = "terraform"
      }
      description = "Team 2 specific dataset"
      iam_owners   = []
      description = "Team 2 specific dataset"
    }
  }
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the instance will fail"
  type        = bool
  default     = false
}

############spanner variables###############
variable "spanner_instance_name" {
  type    = string
  default = "spanner-01"
}

variable "spanner_node_count" {
  type    = number
  default = 1
}

variable "spanner_db_retention_days" {
  type    = string
  default = "2d"
}

variable "spanner_labels" {
  description = "A mapping of labels to assign to the spanner instance."
  type        = map(string)
  default     = {
    created_by = "terraform"
  }
}


############composer variables###############

variable "composer_name" {
  type        = string
  description = "Name of Composer Environment"
  default     = "composer-01"
}

#variable "composer_master_ipv4_cidr_block" {
#  type = string
#  description = "The IP range in CIDR notation to use for the hosted master network (private cluster)"
#}

variable "network_name" {
  description = "The self_link of the VPC network to use"
  default     = "default"
}

variable "subnetwork_name" {
  description = "The self_link of the VPC subnetwork to use"
  default     = null
}

variable "composer_labels" {
  description = "A mapping of labels to assign to the spanner instance."
  type        = map(string)
  default     = {
    created_by = "terraform"
  }
}

##################Cloud storage Variables############
variable "gcs_buckets" {
  description = "The attributes for creating Cloud storage buckets"
  type        = map(object({
    uniform_bucket_level_access = string
    labels                      = map(string)
  }, ))

  default = {
    "customer-data" = {
      uniform_bucket_level_access = "true"
      labels                      = {
        owner = "platform"
        created_by = "terraform"
      }
    },
    "resources" = {
      uniform_bucket_level_access = "true"
      labels                      = {
        owner = "platform"
        created_by = "terraform"
      }
    }
  }
}

################## Artifact Registry Variables############
#variable "artifact_repo_labels" {
#  description = "A mapping of labels to assign to the spanner instance."
#  type        = map(string)
#}
#
#variable "artifact_repo_description" {
#  description = "An optional description for the repository."
#  type        = string
#  default     = "Terraform-managed registry"
#}
#
#variable "artifact_repo_format" {
#  description = "Repository format. One of DOCKER or UNSPECIFIED."
#  type        = string
#  default     = "DOCKER"
#}

variable "artifact_repo_iam" {
  description = "IAM bindings in {ROLE => [MEMBERS]} format."
  type        = map(list(string))
  default     = {}
}

variable "artifact_repo_name" {
  description = "Repository Name. The repo is created outside of Terraform"
  type        = string
}

################## Dataflow Variables############

## Data Catalog variables

# Data Catalog Variables
variable "data_catalog_activated_policy_types" {
  description = "A list of policy types that are activated for this taxonomy."
  type        = list(string)
  default     = ["FINE_GRAINED_ACCESS_CONTROL"]
}

variable "data_catalog_taxonomy_name" {
  type        = string
  description = "the name for the taxonomy"
  default     = "default_taxonomy"
}

variable "data_catalog_taxonomy_tags" {
  description = "List of Data Catalog Policy tags to be created with optional IAM binging configuration in {tag => {ROLE => [MEMBERS]}} format."
  type        = map(map(list(string)))
  nullable    = false
  default     = {}
}

variable "cloud_run_timeout_seconds" {
  description = "Max period for the cloud run service to complete a request. Otherwise, it terminates with HTTP 504"
  type        = number
  default     = 60
}

variable "customer_scoring_service_image" {
  type = string
}

variable "customer_dataflow_flex_template_spec" {
  type        = string
  description = "gcs path the JSON spec file for the customer dataflow pipeline"
}

# project name will be used as a prefix
variable "dataflow_bucket_name_suffix" {
  type        = string
  description = "GCS bucket to store dataflow resources"
  default     = "dataflow"
}

variable "dataflow_sa_name" {
  type    = string
  default = "dataflow-sa"
}

variable "cloudrun_sa_name" {
  type    = string
  default = "cloudrun-sa"
}

variable "composer_sa_name" {
  type    = string
  default = "composer-sa"
}

