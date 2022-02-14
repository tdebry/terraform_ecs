# RealWorld (Conduit) Demo App 
## AWS Elastic Container Service Setup

This directory, vpc, creates the following resoures:
- VPC - The Virtual Private Cloud where all other resources will be created. Named 'Core' by default, but can be set using a variable named vpc_name.
- Egress Only Internet Gateway - Internet gateway for IPv6 traffic.
- Internet Gateway - Internet gateway for IPv4 traffic.
- Public Subnets - Publicly exposed subnets for allowing internet traffic to access the app via a load balancer.
- Private Subnets - Internal subnets for application hosts.
- Security Group - A Security Group for the build instance that allows inbound SSH traffic from a single IP address.
- EC2 Instance - An EC2 instance used for building the app.

This directory contains the following Terraform files:
- vpc.tf - The Terraform module that creates the resources listed above.
- core_launch.tfvars - A Terraform variable file that specifies the following variables:
```
aws_region - AWS Region to be used for creating the resources listed above.
octet2 - Second octet value of the VPC's IPv4 cidr block.
key_name - Name of the key pair to use when launching EC2 instances.
ami_id - AMI ID to use when launching the build instance.
```

Usage:
```
terraform --var-file <path_to_credentials_variable_file> --var-file core_launch.tfvars
```
