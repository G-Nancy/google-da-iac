resource "google_artifact_registry_repository" "registry" {
  provider      = google-beta
  project       = var.project
  location      = var.location
  description   = var.description
  format        = var.format
  labels        = var.labels
  repository_id = var.id
}

resource "google_artifact_registry_repository_iam_binding" "bindings" {
  provider   = google-beta
  for_each   = var.iam
  project    = var.project
  location   = google_artifact_registry_repository.registry.location
  repository = google_artifact_registry_repository.registry.name
  role       = each.key
  members    = each.value
}