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

############ Artifact repository variables###############
artifact_repo_id = "dataplatform-v1"
artifact_repo_format = "docker"
artifact_repo_description = "Docker repository"
artifact_repo_iam = {
  "roles/artifactregistry.admin" = ["user:gnancy@google.com"]
}
artifact_repo_labels = {
  owner="e-digital" #Only lowercase char
}

################## IAM Variables############
df_project_permissions =  [
  "roles/dataflow.admin",
  "roles/run.invoker", # to invoke cloud run
  "roles/bigquery.dataEditor", # to create tables and load data
  "roles/bigquery.jobUser", # to create bigquery load/query jobs
  "roles/artifactregistry.reader",
  "roles/dataflow.worker",
  "roles/storage.admin",
]

df_sa_name = "sa-dataflow-admin"
cr_sa_name = "sa-cloudrun-admin"

################## Data Catalog Variables############
tags       = {
  low = null
  medium = null
  high = {"roles/datacatalog.categoryFineGrainedReader" = ["group:GROUP_NAME@example.com"]}
}
dc_tx_name = "test-policy-tags"
activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
