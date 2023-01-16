# Composer Module Example

This example illustrates how to use the `composer` module. 


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cloud\_master\_ipv4\_cidr\_block | The CIDR block from which IP range in tenant project will be reserved. | `string` | `null` | no |
| composer\_env\_name | Name of Cloud Composer Environment | `string` | n/a | yes |
| master\_ipv4\_cidr | The CIDR block from which IP range in tenant project will be reserved for the master. | `string` | `null` | no |
| orch_network | The VPC network to host the composer cluster. | `string` | n/a | yes |
| region | Region where the Cloud Composer Environment is created. | `string` | `"us-central1"` | no |
| project| Project ID where Cloud Composer Environment is created. | `string` | n/a | yes |
| orch_subnetwork | The subnetwork to host the composer cluster. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| composer\_sa\_email | n/a |



To provision this example, run the following from within this directory:
- `terraform init` to get the plugins
- `terraform plan` to see the infrastructure plan
- `terraform apply` to apply the infrastructure build
- `terraform destroy` to destroy the built infrastructure