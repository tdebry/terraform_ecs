#RealWorld (Conduit) Demo App 
##AWS Elastic Container Service Setup

This directory, iam, creates the following resources:
- IAM Policy - An IAM Policy that allow access to Elastic Container Registries.
- IAM Role - An IAM Role named ecsInstance used by container hosts and an IAM Role named ecsTaskExecution used by ECS tasks.
- Instance Profile - An instance profile attached to container hosts


This directory contains the following Terraform files:
- iam.tf - The Terraform module that creates the resources listed above.
- core_launch.tfvars - A Terraform variable file that specifies the following variables:
```
aws_region - AWS Region to be used for creating the resources listed above.
```

Usage:
```
terraform --var-file <path_to_credentials_variable_file> --var-file core_launch.tfvars
```
