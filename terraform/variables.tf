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

variable "lz_dataset_labels" {
  description = "A mapping of labels to assign to the table."
  type        = map(string)
}

variable "view_dataset_labels" {
  description = "A mapping of labels to assign to the table."
  type        = map(string)
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


