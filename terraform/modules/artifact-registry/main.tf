
# artifact repo is created outside of Terraform because it cause a circular dependency
# with cloud run since the service image must be pushed outside of terraform to a repo

#resource "google_artifact_registry_repository" "registry" {
#  provider      = google-beta
#  project       = var.project
#  location      = var.location
#  description   = var.description
#  format        = var.format
#  labels        = var.labels
#  repository_id = var.id
#}

resource "google_artifact_registry_repository_iam_binding" "bindings" {
  provider   = google-beta
  for_each   = var.iam
  project    = var.project
  location   = var.location
  repository = var.repository_id
  role       = each.key
  members    = each.value
}