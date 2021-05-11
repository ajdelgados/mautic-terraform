provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "tf-aws-us-east-1.om"
    key    = "ec2_mautic/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "terraform-instance" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "LlaveAWS"
  security_groups = ["mautic-general"]

  tags = {
    Name = "terraform-instance"
  }

  volume_tags = {
    Name = "terraform-instance"
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name                = "cpu-utilization"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300" #seconds
  statistic                 = "Average"
  threshold                 = "60"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions                = { InstanceId = aws_instance.terraform-instance.id }
  alarm_actions = ["arn:aws:sns:us-east-2:579010345876:mautic-alert"]
}

resource "aws_cloudwatch_metric_alarm" "ec2_fail" {
  alarm_name                = "check-fail"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "300" #seconds
  statistic                 = "Average"
  threshold                 = "0.99"
  alarm_description         = "This metric monitors ec2 fail"
  insufficient_data_actions = []
  dimensions                = { InstanceId = aws_instance.terraform-instance.id }
  alarm_actions = ["arn:aws:sns:us-east-2:579010345876:mautic-alert"]
}

resource "aws_dlm_lifecycle_policy" "terraform-instance" {
  description        = "terraform-instance DLM lifecycle policy"
  execution_role_arn = "arn:aws:iam::579010345876:role/service-role/AWSDataLifecycleManagerDefaultRole"
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]

    schedule {
      name = "1 daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["04:00"]
      }

      retain_rule {
        count = 30
      }

      tags_to_add = {
        Name = "terraform-instance"
      }

      copy_tags = false
    }

    target_tags = {
      Name = "terraform-instance"
    }
  }
}
