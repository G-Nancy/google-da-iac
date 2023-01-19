variable "project" {
  type = string
  description = "GCP project id"
}

variable "region" {
  type = string
  description = "The region the resources will be created in"

}

variable "zone" {
  type = string
  description = "The zone the resources will be created in"

}

variable "composer_service_account_email" {
  type = string
  description = "Name of Composer Environment"
}

variable "composer_name" {
  description = "Name of Composer Environment"
}

variable "composer_machine_type" {
  description = "Composer machine type"
  default     = "n1-standard-1"
}

#variable "composer_master_ipv4_cidr_block" {
#  description = "The IP range in CIDR notation to use for the hosted master network (private cluster)"
#}

variable "composer_image_version" {
  description = "The version of the software running in the environment"
  default     = "composer-1.20.2-airflow-2.3.4"
}

variable "composer_pypi_packages" {
  description = "Custom Python Package Index (PyPI) packages to be installed in the environment"
  type        = map
  default     = {} #e.g.         numpy = "" scipy = "==1.1.0"
}

variable "composer_python_version" {
  description = "The major version of Python used to run the Apache Airflow scheduler, worker, and webserver processes"
  default     = "3"
}

variable "composer_node_count" {
  description = "The number of nodes in the Kubernetes Engine cluster that will be used to run this environment"
  default     = 3
}

variable "composer_node_storage_gb" {
  description = "The disk size in GB used for Composer node VMs"
  default     = 30
}

variable "orch_network" {
  description = "The self_link of the VPC network to use"
}

variable "orch_subnetwork" {
  description = "The self_link of the VPC subnetwork to use"
}

variable "composer_labels" {
  description = "A mapping of labels to assign to the spanner instance."
#  type        = map(string)
}

variable "env_variables" {
  type = map(string)
}