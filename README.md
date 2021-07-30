# Aviatrix Sandbox Starter

### Description
This module deploys the [Aviatrix Sandbox Starter](https://community.aviatrix.com/t/g9hx9jh/aviatrix-sandbox-starter-tool-spin-up-cloud-networks-in-minutes) to help spin up cloud networks in minutes. Deployment options include:

- Launch Aviatrix Controller in AWS
- Launch connected Aviatrix Transit and Spoke VPCs in AWS
- Launch EC2 instances in spoke VPCs for connectivity validation
- Launch connected Aviatrix Transit and Spoke VPCs in Azure
- Build Transit Peering between AWS and Azure

### Compatibility
| Module version | Terraform version | Controller version | Terraform provider version |
| :------------- | :---------------- | :----------------- | :------------------------- |
| v1.0.1         | >=0.13            | N/A                | N/A                        |
| v1.0.0         | 0.13              | N/A                | N/A                        |

### Diagram

Supported infrastructure result:
<img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-aws-sandbox-starter/blob/master/img/sst.png?raw=true">

### Usage Examples

Deploy the sandbox starter in its own vpc in a public subnet.
```
module "sst" {
  source       = "terraform-aviatrix-modules/aws-sandbox-starter/aviatrix"
  version      = "1.0.1"
  keypair_name = "my_ssh_keypair"
}

output "sandbox_starter_url" {
  description = "The url for the sst instance"
  value       = "https://${module.sst.ip}"
}
```

Deploy the sandbox starter in an existing vpc (whose public subnet has 'public' in its name).
```
module "sst" {
  source       = "terraform-aviatrix-modules/aws-sandbox-starter/aviatrix"
  version      = "1.0.1"
  keypair_name = "my_ssh_keypair"
  vpc_id       = "vpc-0a12345678b9c012d3"
}

output "sandbox_starter_url" {
  description = "The url for the sst instance"
  value       = "https://${module.sst.ip}"
}
```

Deploy the sandbox starter in an existing vpc in an explicit public subnet.
```
module "sst" {
  source       = "terraform-aviatrix-modules/aws-sandbox-starter/aviatrix"
  version      = "1.0.1"
  keypair_name = "my_ssh_keypair"
  vpc_id       = "vpc-0a12345678b9c012d3"
  subnet_id    = "subnet-0123ab456c78d901e"
}

output "sandbox_starter_url" {
  description = "The url for the sst instance"
  value       = "https://${module.sst.ip}"
}
```

Deploy the sandbox starter in an existing vpc in an explicit private subnet.
```
module "sst" {
  source       = "terraform-aviatrix-modules/aws-sandbox-starter/aviatrix"
  version      = "1.0.1"
  keypair_name = "my_ssh_keypair"
  private      = true
  vpc_id       = "vpc-0a12345678b9c012d3"
  subnet_id    = "subnet-0123ab456c78d901e"
}

output "sandbox_starter_url" {
  description = "The url for the sst instance"
  value       = "https://${module.sst.ip}"
}
```

### Variables
The following variables are required:

| key          | value                                        |
| ------------ | -------------------------------------------- |
| keypair_name | AWS keypair in the same region as deployment |


The following variables are optional:

| key       | default | value                                                                                                                                                             |
| :-------- | :------ | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| vpc_id    | null    | The ID of the vpc to use for the sandbox. starter.                                                                                                                |
| subnet_id | null    | The ID of the subnet to use for the sandbox starter. Requires vpc_id.                                                                                             |
| private   | false   | Whether to deploy the sandbox starter to a private or public subnet. This also determines whether the instance private or public id is returned as module output. |

### Outputs
This module will return the following objects:

| key  | description                                                                                                                                                                        |
| :--- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ip   | The IP address for the sandbox starter. Public IP or private IP is determined by the value of the 'private' variable (default is `false`, can be overwritten by module parameter). |
