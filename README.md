# erste-digital-poc
Google PSO POC project for Erste Digital - for internal collaboration

# Project
```shell
domain: wadie.joonix.net

project: pso-erste-digital-sandbox
```
# Terraform

#### Set Variables
```shell
export PROJECT_ID=pso-erste-digital-sandbox
export COMPUTE_REGION=
export ACCOUNT=<current user account email>
expoert BUCKET=<terraform state bucket>
export TF_SA=<service account name used by terraform>
```

#### Prepare Terraform State Bucket

```shell
gsutil mb -p $PROJECT_ID -l $COMPUTE_REGION -b on $BUCKET
```

#### Prepare Terraform Service Account

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

```shell
./scripts/prepare_terraform_service_account.sh
```

#### Deploy Terraform

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

```shell
./scripts/deploy_terraform.sh
```