variable "subaccount_access_key" {}
variable "subaccount_secret_key" {}
variable "aws_region" {}

provider "aws" {
  access_key = var.subaccount_access_key
  secret_key = var.subaccount_secret_key
  region = var.aws_region
}

resource "aws_iam_role" "ecsInstance" {
  name = "ecsInstanceRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecsInstance" {
  role = aws_iam_role.ecsInstance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecsInstance" {
  name = "ecsInstanceRole"
  role = aws_iam_role.ecsInstance.name
}

resource "aws_iam_policy" "ecs-access-ecr" {
  name = "ecs_access_ecr"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:BatchCheckLayerAvailability",
                "ecr:BatchGetImage",
                "ecr:GetDownloadUrlForLayer",
                "ecr:GetAuthorizationToken"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role" "ecs-task-execution" {
  name = "ecsTaskExecution"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ecs-tasks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "instance-ecs" {
  role = aws_iam_role.ecs-task-execution.name
  policy_arn = aws_iam_policy.ecs-access-ecr.arn
}

resource "aws_iam_role_policy_attachment" "instance-task-execution" {
  role = aws_iam_role.ecs-task-execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

