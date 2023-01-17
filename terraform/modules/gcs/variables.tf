variable "gcs_e_bkt_list" {
  description = "The attributes for creating Cloud storage buckets"
  type = map(object({
    name = string,
    location = string,
    uniform_bucket_level_access = string
    labels = map(string)
  },))
  default = {}
}