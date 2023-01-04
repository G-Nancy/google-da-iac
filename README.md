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

#### Notes

* We're using the default VPC
* To use dataflow with private IPs one must enable Google Private Access on the subnetwork. This is done manually (https://cloud.google.com/vpc/docs/configure-private-google-access#console_2) in the POC
project on europe-west3 subnetwork in the default VPC. Dataflow job must be submitted to region europe-west3 in that case.
* On the actual project, a shared VPC is expected and the subnetwork has to enable Google Private Access. Dataflow jobs are then submitted
 to the desired subnetwork via the --subnetwork param