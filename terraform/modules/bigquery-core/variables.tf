variable "project" {
  type = string
}

variable "region" {
  type = string
}

variable "lz_dataset" {
  type = string
}

variable "cr_dataset" {
  type = string
}

variable "cm_dataset" {
  type = string
}

variable "table_dataset_labels" {
  description = "A mapping of labels to assign to the table."
  type        = map(string)
}

variable "view_dataset_labels" {
  description = "A mapping of labels to assign to the table."
  type        = map(string)
}

variable "lz_tables" {
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