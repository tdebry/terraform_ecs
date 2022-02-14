# RealWorld (Conduit) Demo App 
## AWS Elastic Container Service Setup

This directory, app, creates the following resoures:
- Security Groups - Security Groups for the Application Load Balancer and the EC2 container host instances.
- Target Group - Target Group of the EC2 container host instances.
- Launch Configuration - Defines the instance configuration for the EC2 container hosts.
- Auto Scaling Group - Scales the EC2 container host instances.
- Load Balancer - Takes web traffic for the application and sends it to the EC2 container hosts.
- Listeners - Listeners for ports 80 and 443. The port 80 listener redirects to the port 443 listener. The port 443 listener forwards to the Target Group.
- ECS Cluster - The application's Elastic Container Service Cluster.
- ECS Task - The initial Task Definition for the application.
- ECS Service - The applicaiton's ECS service definition.

This directory contains the following Terraform files:
- app_container.tf - The Terraform module that creates the resources listed above.
- conduit_launch_demo_01.tfvars - A Terraform variable file that specifies the following variables:
```
aws_region - AWS Region to be used for creating the resources listed above.
environment_type - Type of environment: qa|stage|prod|demo
key_name - Name of the key pair to use when launching EC2 container hosts.
ami_id - AMI ID to use when launching EC2 container hosts.
environment_index - Numeric identifier for the type of environment expressed as a two digit string starting with "01".
app_name - Name of the application, which is used for naming resources.
domain_name - Domain name, used to determine the certificate to the Load Balancer.

```
- taskDefinition.json - Initial ECS Task Definition.
- user_data.sh - EC2 Instance user data script that creates the /etc/ecs/ecs.config configuration file and is used by the ECS agent to identify the cluster to join.

Usage:
```
terraform --var-file <path_to_credentials_variable_file> --var-file conduit_launch_demo_01.tfvars
```
