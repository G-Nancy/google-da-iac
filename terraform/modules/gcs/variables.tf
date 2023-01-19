variable "project" {
  type = string
}

variable "compute_region" {
  type = string
}

variable "data_region" {
  type = string
}

variable "dataflow_bucket_name_suffix" {
  type = string
  description = "GCS bucket to store dataflow resources"
}

variable "gcs_buckets" {
  description = "The attributes for creating Cloud storage buckets"
  type = map(object({
    uniform_bucket_level_access = string
    labels = map(string)
  },))
  default = {}
}