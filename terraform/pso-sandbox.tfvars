
deployment_version = "1.0"
project = "pso-erste-digital-sandbox-02"
environment_level = "poc"
compute_region = "europe-west3"
composer_zone = "europe-west3-a"
data_region = "eu"
terraform_service_account = "sa-terraform@pso-erste-digital-sandbox-02.iam.gserviceaccount.com"
artifact_repo_name = "data-platform-docker-repo"
customer_scoring_service_image = "europe-west3-docker.pkg.dev/pso-erste-digital-sandbox-02/data-platform-docker-repo/services/example-customer-scoring-java:latest"
customer_dataflow_flex_template_spec = "gs://pso-erste-digital-sandbox-02-dataflow/flex-templates/batch-example-java/batch-example-java-metadata.json"