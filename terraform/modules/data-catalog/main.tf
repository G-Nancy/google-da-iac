resource "google_data_catalog_tag_template" "basic_tag_template" {
  tag_template_id = "my_template"
  region = var.region
  display_name = "Demo Tag Template"

  fields {
    field_id = "country"
    display_name = "country of data asset"
    type {
      primitive_type = "STRING"
    }
    is_required = false
  }

  fields {
    field_id = "num_rows"
    display_name = "Number of rows in the data asset"
    type {
      primitive_type = "DOUBLE"
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

  force_delete = "false"
}

#resource "google_data_catalog_taxonomy" "default_taxonomy" {
#  provider               = google-beta
#  project                = var.project
#  region                 = var.region
#  display_name           =  title("${var.domain} Taxonomy") #local.name
#  description            = var.description
#  activated_policy_types = var.activated_policy_types
#}
#
#resource "google_data_catalog_policy_tag" "default_tags" {
#  for_each     = toset(keys(var.tags))
#  provider     = google-beta
#  taxonomy     = google_data_catalog_taxonomy.default_taxonomy.id
#  display_name = each.key
#  description  = "${each.key} - Terraform managed.  "
#}

