resource "google_data_catalog_taxonomy" "default_taxonomy" {
  provider               = google-beta
  project                = var.project
  region                 = var.region
  display_name           = var.name
  description            = var.description
  activated_policy_types = var.activated_policy_types
}

resource "google_data_catalog_policy_tag" "default_tags" {
  for_each     = toset(keys(var.tags))
  provider     = google-beta
  taxonomy     = google_data_catalog_taxonomy.default_taxonomy.id
  display_name = each.key
  description  = "${each.key} - Terraform managed.  "
}

#################### Sample Tag template #######
resource "google_data_catalog_tag_template" "customer" {
  tag_template_id = "customer"
  region          = "europe-west3"
  display_name    = "customer"

  fields {
    #
    field_id     = "contact_type"
    display_name = "contact_type"
    is_required  = true
    type {
      enum_type {
        allowed_values {
          display_name = "Individual"
        }
        allowed_values {
          display_name = "Group"
        }
      }
    }
  }

  fields {
    field_id     = "epost"
    display_name = "E-post"
    is_required  = true
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id     = "Phone"
    display_name = "Phone"
    is_required  = false # changed from true
    type {
      primitive_type = "STRING"
    }
  }

  fields {
    field_id = "pii_type"
    display_name = "PII type"
    type {
      enum_type {
        allowed_values {
          display_name = "EMAIL"
        }
        allowed_values {
          display_name = "SOCIAL SECURITY NUMBER"
        }
        allowed_values {
          display_name = "NONE"
        }
      }
    }
  }

  force_delete = "true"
}