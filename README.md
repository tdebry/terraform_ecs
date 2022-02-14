# RealWorld (Conduit) Demo App 
## AWS Elastic Container Service Setup

The following directories contain Terraform modules that will setup an AWS account with the resources needed to host the Conduit demo app (listed in run order):
- vpc - creates the VPC/subnets/build host
- iam - creates IAM roles/profiles
- app - creates the ECS cluster and related resources
- route53 - creates DNS records
For each module two variable files are required. 
One must include AWS IAM credentials:
```
subaccount_access_key = “<ACCESS_KEY>“
subaccount_secret_key = “<SECRET_KEY>”
```
This variable file should not be committed to source control.

 The other variable file contains the variables that describe the environment being created and is included in source control.
