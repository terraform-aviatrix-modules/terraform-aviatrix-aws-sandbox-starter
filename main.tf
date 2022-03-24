# Latest Sandbox Starter AMI
data "aws_ami" "sst" {
  most_recent = true
  owners      = ["503512322177"] #Aviatrix
  filter {
    name   = "name"
    values = ["Aviatrix Sandbox Starter*"]
  }
}

# Grab the source IP that is launching the sst
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Sandbox starter will be deployed to the region of the configured calling provider
data "aws_region" "current" {}

# Detect private and public subnets if a vpc_id is passed. Naming convention of public|private required in the subnet name. Otherwise
# subnet_id needs to be passed into the module.
data "aws_subnet_ids" "private" {
  count  = var.vpc_id == null ? 0 : 1
  vpc_id = var.vpc_id

  tags = {
    Name = "*rivate*"
  }
}

data "aws_subnet_ids" "public" {
  count  = var.vpc_id == null ? 0 : 1
  vpc_id = var.vpc_id

  tags = {
    Name = "*ublic*"
  }
}

# Create a vpc if an existing id is not provided
module "vpc" {
  count              = var.vpc_id == null ? 1 : 0
  source             = "terraform-aws-modules/vpc/aws"
  version            = "3.0.0"
  name               = var.common_tags.Name
  cidr               = local.cidr
  azs                = ["${data.aws_region.current.name}a"]
  public_subnets     = [cidrsubnet(local.cidr, 4, 0)]
  private_subnets    = [cidrsubnet(local.cidr, 4, 1)]
  enable_nat_gateway = var.private ? true : false
  public_subnet_tags = {
    Name = "${var.common_tags.Name}-public"
  }

  tags = var.common_tags
}

# Security Group and rules for the SST instance
resource "aws_security_group" "sst" {
  name        = var.common_tags.Name
  description = "Security group for Aviatrix Sandbox Starter"
  vpc_id      = var.vpc_id == null ? module.vpc[0].vpc_id : var.vpc_id
  tags        = var.common_tags
}

resource "aws_security_group_rule" "sst_ingress" {
  type              = "ingress"
  description       = "Allows HTTPS ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"] # locked to the source ip that launched the sst
  security_group_id = aws_security_group.sst.id
}

resource "aws_security_group_rule" "sst_egress_https" {
  type              = "egress"
  description       = "Allows HTTPS egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sst.id
}

resource "aws_security_group_rule" "sst_egress_http" {
  type              = "egress"
  description       = "Allows HTTP egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sst.id
}

# Aviatrix Sandbox Starter
resource "aws_instance" "sst" {
  ami                    = data.aws_ami.sst.id
  instance_type          = "t3.micro"
  ebs_optimized          = false
  monitoring             = false
  key_name               = var.keypair_name
  subnet_id              = var.subnet_id == null ? local.calculated_subnet_id : var.subnet_id
  vpc_security_group_ids = [aws_security_group.sst.id]

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = var.common_tags
}
