variable "common_tags" {
  description = "Common tags applied to all infrastructure"
  default = {
    Name      = "aviatrix-sandbox-starter"
    Team      = "aviatrix"
    Terraform = true
  }
}

variable "vpc_id" {
  description = "The ID of the vpc to use for the sandbox starter"
  default     = null
}

variable "subnet_id" {
  description = "The ID of the subnet to use for the sandbox starter"
  default     = null
}

variable "keypair_name" {
  description = "EC2 keypair to use for the instance"
}

variable "private" {
  description = "Deploy sst to a private subnet"
  default     = false
}

locals {
  cidr                 = "10.0.0.0/24"
  private_subnet_id    = var.vpc_id == null ? module.vpc[0].private_subnets[0] : sort(data.aws_subnet_ids.private[0].ids)[0]
  public_subnet_id     = var.vpc_id == null ? module.vpc[0].public_subnets[0] : sort(data.aws_subnet_ids.public[0].ids)[0]
  calculated_subnet_id = var.private ? local.private_subnet_id : local.public_subnet_id
}
