# RealWorld (Conduit) Demo App 
## AWS Elastic Container Service Setup

This directory, route53, creates the following resoures:
- Route 53 Records - A record for the app, such as conduit.tomdebry.com, and the build host, such as build.conduit.tomdebry.com

This directory contains the following Terraform files:
- route53.tf - The Terraform module that creates the resources listed above.
- conduit_launch_demo.tfvars - A Terraform variable file that specifies the following variables:
```
aws_region - AWS Region to be used for creating the resources listed above.
environment_type - Type of environment: qa|stage|prod|demo
environment_index - Numeric identifier for the type of environment expressed as a two digit string starting with "01".
app_name - Name of the application, which is used for naming resources.
domain_name - Domain name, used to determine the Route53 Zone for creating the records.
```

Usage:
```
terraform --var-file <path_to_credentials_variable_file> --var-file conduit_launch_demo.tfvars
```
