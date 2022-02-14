variable "subaccount_access_key" {}
variable "subaccount_secret_key" {}
variable "aws_region" {}
variable "vpc_name" {
  default = "Core"
}
variable "environment_type" {}
variable "key_name" {}
variable "app_name" {}
variable "domain_name" {}
variable "ami_id" {}
variable "instance_type" {
  default = "t3a.small"
}
variable "environment_index" {
  default = "01"
}

provider "aws" {
  access_key = var.subaccount_access_key
  secret_key = var.subaccount_secret_key
  region = var.aws_region
}

data "aws_vpc" "Core" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnet" "PublicWeb-A" {
  tags = {
    Name = "PublicWeb-A"
  }
}

data "aws_subnet" "PublicWeb-B" {
  tags = {
    Name = "PublicWeb-B"
  }
}

data "aws_subnet" "PublicWeb-C" {
  tags = {
    Name = "PublicWeb-C"
  }
}

data "aws_subnet" "PrivateContainer-2A" {
  tags = {
    Name = "PrivateContainer-2A"
  }
}

data "aws_subnet" "PrivateContainer-2B" {
  tags = {
    Name = "PrivateContainer-2B"
  }
}

data "aws_subnet" "PrivateContainer-2C" {
  tags = {
    Name = "PrivateContainer-2C"
  }
}

data "aws_iam_instance_profile" "ecsInstanceRole" {
  name = "ecsInstanceRole"
}

data "aws_acm_certificate" "domain" {
  domain = format("*.%s", var.domain_name)
  statuses = ["ISSUED"]
  most_recent = true
}

data "aws_iam_role" "task-execution" {
  name = "ecsTaskExecution"
}

resource "aws_security_group" "app_lb" {
  name = format("%s-%s-%s-elb-sg", var.app_name, var.environment_type, var.environment_index)
  description = format("Elastic Load Balancer Security Group for %s %s-%s.", var.app_name, var.environment_type, var.environment_index)
  vpc_id = data.aws_vpc.Core.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Web traffic on port 80."
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "Web traffic on port 80."
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
    Name = format("%s-%s-%s-elb-sg", var.app_name, var.environment_type, var.environment_index)
  }
}

resource "aws_security_group" "app_instance" {
  name = format("%s-%s-%s-instance-sg", var.app_name, var.environment_type, var.environment_index)
  description = format("Instance Security Group for %s %s-%s.", var.app_name, var.environment_type, var.environment_index)
  vpc_id = data.aws_vpc.Core.id
  ingress {
    from_port = 4100
    to_port = 4100
    protocol = "tcp"
    security_groups = [aws_security_group.app_lb.id]
    description = "Web traffic from elb on port 4100."
  }
  egress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "HTTP"
  }
  egress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "HTTPS"
  }
  egress {
    from_port = 123
    to_port = 123
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    description = "NTP"
  }
  tags = {
    Name = format("%s-%s-%s-instance-sg", var.app_name, var.environment_type, var.environment_index)
  }
}


resource "aws_lb_target_group" "app" {
  name = format("%s-%s-%s-tg", var.app_name, var.environment_type, var.environment_index)
  port = 4100
  protocol = "HTTP"
  vpc_id = data.aws_vpc.Core.id
  deregistration_delay = "60"
  target_type = "instance"
}

resource "aws_launch_configuration" "app" {
  name = format("%s-%s-%s-lc", var.app_name, var.environment_type, var.environment_index)
  image_id = var.ami_id
  instance_type = var.instance_type
  key_name = var.key_name
  security_groups = [aws_security_group.app_instance.id]
  root_block_device {
    volume_type = "gp2"
    volume_size = "30"
  }
  user_data = replace(file("./user_data.sh"), "CLUSTER_NAME", format("%s-%s-%s-cluster", var.app_name, var.environment_type, var.environment_index))
  iam_instance_profile = data.aws_iam_instance_profile.ecsInstanceRole.arn
  associate_public_ip_address = true
}

resource "aws_autoscaling_group" "app" {
  name = format("%s-%s-%s-asg", var.app_name, var.environment_type, var.environment_index)
  max_size = 4
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "EC2"
  desired_capacity = 2
  launch_configuration = aws_launch_configuration.app.name
  vpc_zone_identifier = [data.aws_subnet.PublicWeb-A.id, data.aws_subnet.PublicWeb-B.id]
  target_group_arns = [aws_lb_target_group.app.arn]
  tag {
    key = "Name"
    value = format("%s-%s-%s", var.app_name, var.environment_type, var.environment_index)
    propagate_at_launch = true
  }
}

resource "aws_lb" "app" {
  name = format("%s-%s-%s-elb", var.app_name, var.environment_type, var.environment_index)
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.app_lb.id]
  subnets = [data.aws_subnet.PublicWeb-A.id, data.aws_subnet.PublicWeb-B.id]
  ip_address_type = "dualstack"
}

resource "aws_lb_listener" "app_http" {
  load_balancer_arn = aws_lb.app.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "redirect"
    redirect {
    	port = "443"
    	protocol = "HTTPS"
    	status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "app_https" {
  load_balancer_arn = aws_lb.app.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS-1-1-2017-01"
  certificate_arn = data.aws_acm_certificate.domain.arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_ecs_cluster" "app" {
  name = format("%s-%s-%s-cluster", var.app_name, var.environment_type, var.environment_index)
}

resource "aws_ecs_task_definition" "app" {
  family = format("%s-%s-%s-task", var.app_name, var.environment_type, var.environment_index)
  execution_role_arn = data.aws_iam_role.task-execution.arn
  container_definitions = file("./taskDefinition.json")
  requires_compatibilities = ["EC2"]
}

resource "aws_ecs_service" "app" {
  name = format("%s-%s-%s-service", var.app_name, var.environment_type, var.environment_index)
  cluster = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count = 2
  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent = 100
  load_balancer {
    target_group_arn = aws_lb_target_group.app.arn
    container_name = var.app_name
    container_port = 4100
  }
}
