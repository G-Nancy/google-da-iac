resource "google_project_service" "required_services" {
  for_each = toset([
    "cloudresourcemanager",
    "iam",
    "datacatalog",
    "dataflow",
    "compute",
    "artifactregistry",
    "bigquery",
    "pubsub",
    "storage",
    "run",
    "serviceusage",
    "appengine",
    "spanner",
    "cloudbuild"
  ])

  service            = "${each.key}.googleapis.com"
  disable_on_destroy = false
}