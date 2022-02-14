variable "subaccount_access_key" {}
variable "subaccount_secret_key" {}
variable "aws_region" {}
variable "octet1" {
  default = "10"
}
variable octet2 {}
variable "vpc_name" {
  default = "Core"
}
variable "key_name" {}
variable "instance_type" {
  default = "t3a.small"
}
variable ami_id {}

locals {
  vpc_IPv4_cidr_block = "${var.octet1}.${var.octet2}.0.0/16"
  private_subnet_container_A_IPv4_cidr = format("%s.%s.104.0/24", var.octet1, var.octet2)
  private_subnet_container_B_IPv4_cidr = format("%s.%s.105.0/24", var.octet1, var.octet2)
  private_subnet_container_C_IPv4_cidr = format("%s.%s.106.0/24", var.octet1, var.octet2)
  public_subnet_web_A_IPv4_cidr = "${var.octet1}.${var.octet2}.1.0/24"
  public_subnet_web_B_IPv4_cidr = "${var.octet1}.${var.octet2}.2.0/24"
  public_subnet_web_C_IPv4_cidr = "${var.octet1}.${var.octet2}.3.0/24"
}

provider "aws" {
  access_key = var.subaccount_access_key
  secret_key = var.subaccount_secret_key
  region = var.aws_region
}

resource "aws_vpc" "Core" {
  cidr_block = local.vpc_IPv4_cidr_block
  enable_dns_support = true
  enable_dns_hostnames = true
  assign_generated_ipv6_cidr_block = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_egress_only_internet_gateway" "Core" {
  vpc_id = aws_vpc.Core.id
}

resource "aws_internet_gateway" "Core" {
  vpc_id = aws_vpc.Core.id
  tags = {
    Name = "Core"
  }
}

resource aws_route "internet" {
	route_table_id = aws_vpc.Core.main_route_table_id
	destination_cidr_block = "0.0.0.0/0"
	gateway_id = aws_internet_gateway.Core.id
}

resource "aws_subnet" "PublicWeb-A" {
  vpc_id = aws_vpc.Core.id
  cidr_block = local.public_subnet_web_A_IPv4_cidr
  ipv6_cidr_block = cidrsubnet(aws_vpc.Core.ipv6_cidr_block, 8, 1)
  availability_zone = format("%sa", var.aws_region)
  tags = {
    Name = "PublicWeb-A"
  }
}

resource "aws_subnet" "PublicWeb-B" {
  vpc_id = aws_vpc.Core.id
  cidr_block = local.public_subnet_web_B_IPv4_cidr
  ipv6_cidr_block = cidrsubnet(aws_vpc.Core.ipv6_cidr_block, 8, 2)
  availability_zone = format("%sb", var.aws_region)
  tags = {
    Name = "PublicWeb-B"
  }
}

resource "aws_subnet" "PublicWeb-C" {
  vpc_id = aws_vpc.Core.id
  cidr_block = local.public_subnet_web_C_IPv4_cidr
  ipv6_cidr_block = cidrsubnet(aws_vpc.Core.ipv6_cidr_block, 8, 3)
  availability_zone = format("%sc", var.aws_region)
  tags = {
    Name = "PublicWeb-C"
  }
}

resource "aws_subnet" "PrivateContainer-2A" {
  vpc_id = aws_vpc.Core.id
  cidr_block = local.private_subnet_container_A_IPv4_cidr
  ipv6_cidr_block = cidrsubnet(aws_vpc.Core.ipv6_cidr_block, 8, 104)
  availability_zone = format("%sa", var.aws_region)
  tags = {
    Name = "PrivateContainer-2A"
  }
}

resource "aws_subnet" "PrivateContainer-2B" {
  vpc_id = aws_vpc.Core.id
  cidr_block = local.private_subnet_container_B_IPv4_cidr
  ipv6_cidr_block = cidrsubnet(aws_vpc.Core.ipv6_cidr_block, 8, 105)
  availability_zone = format("%sb", var.aws_region)
  tags = {
    Name = "PrivateContainer-2B"
  }
}

resource "aws_subnet" "PrivateContainer-2C" {
  vpc_id = aws_vpc.Core.id
  cidr_block = local.private_subnet_container_C_IPv4_cidr
  ipv6_cidr_block = cidrsubnet(aws_vpc.Core.ipv6_cidr_block, 8, 106)
  availability_zone = format("%sc", var.aws_region)
  tags = {
    Name = "PrivateContainer-2C"
  }
}

resource "aws_security_group" "build" {
  name = format("build-sg")
  description = format("Instance Security Group for build hosts.")
  vpc_id = aws_vpc.Core.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["98.48.74.43/32"]
    description = "SSH traffic."
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "All outbound traffic."
  }
  tags = {
    Name = format("build-sg")
  }
}

resource "aws_instance" "build" {
	ami = var.ami_id
	instance_type = var.instance_type
	associate_public_ip_address = true
	key_name = var.key_name
	subnet_id = aws_subnet.PublicWeb-A.id
	vpc_security_group_ids = [aws_security_group.build.id]
  tags = {
    Name = format("Build")
  }
}
