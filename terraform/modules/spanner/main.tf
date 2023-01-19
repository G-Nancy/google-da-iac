locals {
  logt = file("${path.module}/sql/logs.sql")
}

resource "google_spanner_instance" "spanner-instance" {
  project      = var.project
  name         = var.spanner_instance
  config       = "regional-${var.region}"
  display_name = var.spanner_instance
  num_nodes    = var.spanner_node_count
  labels       = var.spanner_labels
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_spanner_database" "database" {
  project  = var.project
  instance = google_spanner_instance.spanner-instance.name
  name     = "${var.spanner_instance}-${random_id.db_name_suffix.hex}"
  ddl                 = [local.logt]
  version_retention_period = var.spanner_db_retention_days
  deletion_protection = false
}