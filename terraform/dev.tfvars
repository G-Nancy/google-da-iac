project        = "pso-erste-digital-sandbox"
compute_region = "europe-west1"
data_region    = "eu"
bq_landing_dataset_name = "erste_bq_landing"
bq_curated_dataset_name = "erste_bq_curated"
bq_consumption_dataset_name = "erste_bq_consumption"

terraform_service_account = "setup-infra-tf@pso-erste-digital-sandbox.iam.gserviceaccount.com"

view_dataset_labels = {
  env      = "dev"
  billable = "true"
  owner    = "e-digital"
}
lz_dataset_labels = {
  env      = "dev"
  billable = "true"
  owner    = "e-digital"
}

bq_lz_tables = [
  {
    table_id           = "lz_customers",
    schema             = "modules/bigquery-core/schema/lz_customer.json",
    time_partitioning  = null,
    range_partitioning = null,
    expiration_time    = 2524604400000, # 2050/01/01
    clustering         = ["country"],
    labels = {
      env      = "devops"
      billable = "true"
      owner    = "e-lz"
    },
  }
]

bq_bi_dataset = {
  bq_team1_dataset ={
    region  = "europe-west1"
    labels = {
      owner="team1"
    }
    description = "Team 1 specific dataset"
    domain_reader = "goyalclouds.com"
    owner = "gnancy@google.com"
    description = "Team 1 specific dataset"
  }
  bq_team2_dataset ={
    region  = "europe-west1"
    labels = {
      owner="karim" #Only lowercase char
    }
    description = "Team 2 specific dataset"
    domain_reader = "goyalclouds.com"
    owner = "wadie@google.com"
    description = "Team 2 specific dataset"
  }

}

####spanner variables#############
spanner_instance = "e-spanner-main"

spanner_node_count = 1

spanner_db_retention_days = "1d"

spanner_labels = {
  env      = "dev"
  billable = "true"
  owner    = "e-digital"
}

#domain_mapping = [
#  {
#    project = "pso-erste-digital-sandbox",
#    domain = "consumer",
#    datasets = [] // leave empty if no dataset overrides is required for this project
#  },
#  {
#    project = "pso-erste-digital-sandbox",
#    domain = "digital",
#    datasets = [
#      {
#        name = "erste_bq_landing",
#        domain = "landing"
#      },
#      {
#        name = "erste_bq_curated",
#        domain = "curated"
#      },
#      {
#        name = "erste_bq_consumption",
#        domain = "consumption"
#      },
#    ]
#  }
#]
#
#activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
