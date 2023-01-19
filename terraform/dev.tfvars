project                     = "pso-erste-digital-sandbox"
compute_region              = "europe-west3"
data_region                 = "eu"
bq_landing_dataset_name     = "erste_bq_landing"
bq_curated_dataset_name     = "erste_bq_curated"
bq_consumption_dataset_name = "erste_bq_consumption"

terraform_service_account = "setup-infra-tf@pso-erste-digital-sandbox.iam.gserviceaccount.com"

bq_landing_tables = [
  {
    table_id           = "customer_stg_1",
    schema             = "/schema/landing/customer_stg.json",
    time_partitioning  = null,
    range_partitioning = null,
    expiration_time    = 2524604400000, # 2050/01/01
    clustering         = [],
    labels             = {
      env      = "devops"
      billable = "true"
      owner    = "e-lz"
    },
  }
]

bq_curated_tables = [
  {
    table_id           = "customer_1",
    schema             = "/schema/curated/customer.json",
    time_partitioning  = null,
    range_partitioning = null,
    expiration_time    = 2524604400000, # 2050/01/01
    clustering         = [],
    labels             = {
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
    labels             = {
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
    labels             = {
      env      = "devops"
      billable = "true"
      owner    = "e-cr"
    },
  }
]

bq_consumption_views = [
  {
    view_id        = "v_customer",
    use_legacy_sql = false,
    table          = "customer"
    query          = "modules/bigquery-core/views/v_cn_customer.tpl"
    labels         = {
      env      = "devops"
      billable = "true"
      owner    = "e-cr"
    },
  },
  {
    view_id        = "v_customer_score",
    use_legacy_sql = false,
    table          = "customer_score"
    query          = "modules/bigquery-core/views/v_cn_customer_score.tpl"
    labels         = {
      env      = "devops"
      billable = "true"
      owner    = "e-cr"
    },
  }
]

deletion_protection = false

bq_consumers_datasets = {
  bq_team1_dataset = {
    region = "europe-west1"
    labels = {
      owner = "team1"
    }
    description   = "Team 1 specific dataset"
    domain_reader = "goyalclouds.com"
    owner         = "gnancy@google.com"
    description   = "Team 1 specific dataset"
  }
  bq_team2_dataset = {
    region = "europe-west1"
    labels = {
      owner = "karim" #Only lowercase char
    }
    description   = "Team 2 specific dataset"
    domain_reader = "goyalclouds.com"
    owner         = "wadie@google.com"
    description   = "Team 2 specific dataset"
  }

}

####spanner variables#############
spanner_instance_name = "e-spanner-main"

spanner_node_count = 1

spanner_db_retention_days = "1d"

spanner_labels = {
  env      = "dev"
  billable = "true"
  owner    = "e-digital"
}

############composer variables###############
composer_zone = "europe-west3-c"

composer_service_account_email = "composer-e-dev"

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
gcs_buckets = [
  {
    name_suffix                 = "customer-data"
    uniform_bucket_level_access = "false"
    labels                      = {
      owner = "team1"
    }
  }
]

############ Artifact repository variables###############
artifact_repo_name = "dataplatform-v1"

################## IAM Variables############
dataflow_sa_project_permissions = [
  "roles/dataflow.admin",
  "roles/run.invoker", # to invoke cloud run
  "roles/bigquery.dataEditor", # to create tables and load data
  "roles/bigquery.jobUser", # to create bigquery load/query jobs
  "roles/artifactregistry.reader",
  "roles/dataflow.worker",
  "roles/storage.admin",
]


################## Data Catalog Variables############
data_catalog_taxonomy_tags = {
  low    = null
  medium = null
  high   = { "roles/datacatalog.categoryFineGrainedReader" = ["group:GROUP_NAME@example.com"] }
}
data_catalog_taxonomy_name          = "test-policy-tags"
data_catalog_activated_policy_types = ["FINE_GRAINED_ACCESS_CONTROL"]
