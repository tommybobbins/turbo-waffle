provider "aws" {
  region = local.region
  default_tags {
    tags = {
      Environment = "Production"
      Owner       = "tommybobbins"
      Project     = var.project_name
    }
  }

}

data "aws_ssm_parameter" "ami_id" {
  #  name = "/aws/service/ubuntu-minimal/images/ubuntu-jammy-22.04-arm64-minimal"
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

#        "ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-arm64-minimal-20230921",
#        "ami-0dfca1d4d33827016

locals {
  vpc_cidr = "10.123.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name            = "${var.project_name}-vpc"
  cidr            = local.vpc_cidr
  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]

  #  enable_nat_gateway           = true
  #  single_nat_gateway           = true
  enable_ipv6                                   = true
  public_subnet_assign_ipv6_address_on_creation = true

  #public_subnet_ipv6_native    = true
  public_subnet_ipv6_prefixes = [0, 1, 2]
  #private_subnet_ipv6_native   = true
  private_subnet_ipv6_prefixes = [3, 4, 5]
  map_public_ip_on_launch      = true

}


resource "aws_security_group" "ec2-sg" {
  vpc_id = module.vpc.vpc_id
  name   = join("_", ["sg", module.vpc.vpc_id])
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port        = ingress.value["port"]
      to_port          = ingress.value["port"]
      protocol         = ingress.value["proto"]
      cidr_blocks      = ingress.value["cidr_blocks"]
      ipv6_cidr_blocks = ingress.value["ipv6_cidr_blocks"]
    }
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.project_name}-dynamic-SG"
  }
}

