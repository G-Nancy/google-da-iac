variable "region" {
  description = "Data Catalog Taxonomy location."
  type = string
}

variable "name" {
  description = "Name of this taxonomy."
  type        = string
}

variable "prefix" {
  description = "Prefix used to generate project id and name."
  type        = string
  default     = null
}

variable "project" {
  description = "GCP project id."
}

variable "domain" {
  type = string
  description = "the domain name for the taxonomy"
}

variable "activated_policy_types" {
  description = "A list of policy types that are activated for this taxonomy."
  type        = list(string)
  default     = ["FINE_GRAINED_ACCESS_CONTROL"]
}

variable "description" {
  description = "Description of this taxonomy."
  type        = string
  default     = "Taxonomy - Terraform managed"
}

variable "tags" {
  description = "List of Data Catalog Policy tags to be created with optional IAM binging configuration in {tag => {ROLE => [MEMBERS]}} format."
  type        = map(map(list(string)))
  nullable    = false
  default     = {}
}

