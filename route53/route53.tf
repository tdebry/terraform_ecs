variable "subaccount_access_key" {}
variable "subaccount_secret_key" {}
variable "aws_region" {}
variable "environment_type" {}
variable "environment_index" {}
variable "app_name" {}
variable "domain_name" {}

provider "aws" {
  access_key = var.subaccount_access_key
  secret_key = var.subaccount_secret_key
  region = var.aws_region
}

data "aws_lb" "app" {
	name = format("%s-%s-%s-elb", var.app_name, var.environment_type, var.environment_index)
}

data "aws_route53_zone" "domain" {
	name = var.domain_name
}

data "aws_instance" "build" {
	filter {
		name = "tag:Name"
		values = ["Build"]
	}
}

resource "aws_route53_record" "app" {
	zone_id = data.aws_route53_zone.domain.zone_id
	name = format("%s.%s", var.app_name, var.domain_name)
	type = "CNAME"
	ttl = "300"
	records = [data.aws_lb.app.dns_name]
}

resource "aws_route53_record" "build" {
	zone_id = data.aws_route53_zone.domain.zone_id
	name = format("build.%s.%s", var.app_name, var.domain_name)
	type = "A"
	ttl = "300"
	records = [data.aws_instance.build.public_ip]
}
