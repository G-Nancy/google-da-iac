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

variable "project" {
  type = string
}

variable "df_sa_name" {
  type = string
}

variable "cr_sa_name" {
  type = string
}

variable "composer_service_account_name" {
  type = string
  description = "Name of Composer Environment"
}
