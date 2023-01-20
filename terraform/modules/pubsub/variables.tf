variable "project" {
  type = string
}
variable "customer_data_topic_name" {
  type = string
}

variable "customer_data_subscription_name" {
  type = string
}

variable "customer_data_subscription_readers" {
  type = list(string)
}
