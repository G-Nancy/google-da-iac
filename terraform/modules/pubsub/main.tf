# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/cloud_scheduler_job


# PubSub topic to send data to
resource "google_pubsub_topic" "customer_data" {
  project = var.project
  name = var.customer_data_topic_name
  labels = {
    created_by = "terraform"
  }
}

resource "google_pubsub_subscription" "customer_data_pull" {
  name  = var.customer_data_subscription_name
  topic = google_pubsub_topic.customer_data.name

  labels = {
    created_by = "terraform"
  }

  # 20 minutes
  message_retention_duration = "1200s"
  retain_acked_messages      = true

  ack_deadline_seconds = 60

  expiration_policy {
    ttl = "300000.5s"
  }
  retry_policy {
    minimum_backoff = "10s"
  }

  enable_message_ordering    = false
}

resource "google_pubsub_subscription_iam_member" "readers" {
  count = length(var.customer_data_subscription_readers)
  subscription = google_pubsub_subscription.customer_data_pull.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${var.customer_data_subscription_readers[count.index]}"
}
