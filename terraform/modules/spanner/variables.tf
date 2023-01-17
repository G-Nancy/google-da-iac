variable "project" {
  type = string
}

variable "region" {
  type = string
}

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