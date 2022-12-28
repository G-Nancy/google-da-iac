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
export BUCKET=<terraform state bucket>
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

#### Enable GCP APIs

```shell
./scripts/enable_gcp_apis.sh
```


#### Terraform Variables Configuration

The solution is deployed by Terraform and thus all configurations are done
on the Terraform side.

##### Create a Terraform .tfvars file

Create a new .tfvars file and override the variables in the below sections. You can use the example
tfavrs files as a base [example-variables](terraform/example-variables.tfvars).

```shell
export VARS=my-variables.tfvars
```

##### Configure Project Variables

Most required variables have default values defined in [variables.tf](terraform/variables.tf).
One can use the defaults or overwrite them in the newly created .tfvars.

Both ways, one must set the below variables:

```yaml
project = "<GCP project ID to deploy solution to (equals to $PROJECT_ID) >"
compute_region = "<GCP region to deploy compute resources e.g. cloud run, iam, etc (equals to $COMPUTE_REGION)>"
data_region = "<GCP region to deploy data resources (buckets, datasets, tag templates, etc> (equals to $DATA_REGION)"
```

##### Configure Terraform Service Account

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

This service account name is defined in the "Setup Environment Variables" step and created
in the "Prepare Terraform Service Account" step.
Use the full email of the created account.
```yaml
terraform_service_account = "${TF_SA}@${PROJECT_ID}.iam.gserviceaccount.com"
```

#### Deploy Terraform

Terraform needs to run with a service account to deploy DLP resources. User accounts are not enough.

```shell
./scripts/deploy_terraform.sh
```