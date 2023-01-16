project        = "pso-erste-digital-sandbox"
compute_region = "europe-west3"
data_region    = "eu"
bq_landing_dataset_name = "erste_bq_landing"
bq_curated_dataset_name = "erste_bq_curated"
bq_consumption_dataset_name = "erste_bq_consumption"

terraform_service_account = "setup-infra-tf@pso-erste-digital-sandbox.iam.gserviceaccount.com"

bq_lz_tables = [
  {
    table_id           = "customer_stg_1",
    schema             = "/schema/landing/customer_stg.json",
    time_partitioning  = null,
    range_partitioning = null,
    expiration_time    = 2524604400000, # 2050/01/01
    clustering         = [],
    labels = {
      env      = "devops"
      billable = "true"
      owner    = "e-lz"
    },
  }
]

bq_cr_tables = [
  {
    table_id           = "customer_1",
    schema             = "/schema/curated/customer.json",
    time_partitioning  = null,
    range_partitioning = null,
    expiration_time    = 2524604400000, # 2050/01/01
    clustering         = [],
    labels = {
      env      = "devops"
      billable = "true"
      owner    = "e-cr"
    },
  },
  {
    table_id           = "customer_stg_1",
    schema             = "/schema/curated/customer_score.json",
    time_partitioning  = null,
    range_partitioning = null,
    expiration_time    = 2524604400000, # 2050/01/01
    clustering         = [],
    labels = {
      env      = "devops"
      billable = "true"
      owner    = "e-cr"
    },
  },
  {
    table_id           = "failed_customer_processing_1",
    schema             = "/schema/curated/failed_record_processing.json",
    time_partitioning  = null,
    range_partitioning = null,
    expiration_time    = 2524604400000, # 2050/01/01
    clustering         = [],
    labels = {
      env      = "devops"
      billable = "true"
      owner    = "e-cr"
    },
  }
]

cm_views = [
  {
    view_id        = "v_customer",
    use_legacy_sql = false,
    table     = "customer"
    query          = "modules/bigquery-core/views/v_cn_customer.tpl"
    labels = {
      env      = "devops"
      billable = "true"
      owner    = "e-cr"
    },
  },
  {
    view_id        = "v_customer_score",
    use_legacy_sql = false,
    table     = "customer_score"
    query          = "modules/bigquery-core/views/v_cn_customer_score.tpl"
    labels = {
      env      = "devops"
      billable = "true"
      owner    = "e-cr"
    },
  }
]

deletion_protection = false

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

############composer variables###############
zone = "europe-west3-c"

composer_service_account_name = "composer-e-dev"

composer_name = "e-dev"

#composer_master_ipv4_cidr_block

network_name = "default"

subnetwork_name = ""

composer_labels = {
env      = "dev"
billable = "true"
owner    = "e-digital"
}


############Cloud Storage variables###############
gcs_e_bkt_list = {
  e-digital-sandbox-data-test ={
    name = "e-digital-sandbox-data-test"
    location  = "europe-west3"
    uniform_bucket_level_access = "false"
    labels = {
      owner="team1"
    }
  }
  e-digital-sandbox-df-test ={
    name = "e-digital-sandbox-df-test"
    location  = "europe-west3"
    uniform_bucket_level_access = "false"
    labels = {
      owner="e-digital" #Only lowercase char
    }
  }
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
