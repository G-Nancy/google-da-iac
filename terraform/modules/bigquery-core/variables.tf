variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "landing_dataset" {
  type = string
}

variable "curated_dataset" {
  type = string
}

variable "consumption_dataset" {
  type = string
}

variable "landing_tables" {
  description = "A list of maps that includes table_id, schema, clustering, time_partitioning, range_partitioning, view, expiration_time, labels in each element."
  default     = []
  type        = list(object({
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
}


variable "curated_tables" {
  description = "A list of maps that includes table_id, schema, clustering, time_partitioning, range_partitioning, view, expiration_time, labels in each element."
  default     = []
  type        = list(object({
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
}

variable "consumption_views" {
  description = "A list of objects which include table_id, which is view id, and view query"
  default     = []
  type        = list(object({
    view_id        = string,
    query          = string,
    table          = string,
    use_legacy_sql = bool,
    labels         = map(string),
  }))
}

variable "bq_consumers_datasets" {
  description = "The attributes for creating consumer teams datasets"
  type        = map(object({
    description = string,
    iam_owners  = list(string),
    labels      = map(string)
  }, ))
  default = {}
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the instance will fail"
  type        = bool
  default     = false
}