resource "aws_instance" "this" {
  ami             = var.ami
  instance_type   = "t2.micro"
  key_name        = "LlaveAWS"
  security_groups = ["mautic-general"]

  tags = {
    Name = var.name
  }

  volume_tags = {
    Name = var.name
  }
}

resource "aws_eip" "this" {
  instance = aws_instance.this.id
  vpc      = true

  tags = {
    Name = var.name
  }
}

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name                = "cpu-utilization-${var.name}-${aws_instance.this.id}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "300" #seconds
  statistic                 = "Average"
  threshold                 = "60"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  dimensions                = { InstanceId = aws_instance.this.id }
  alarm_actions = ["arn:aws:sns:us-east-2:579010345876:mautic-alert"]
}

resource "aws_cloudwatch_metric_alarm" "ec2_fail" {
  alarm_name                = "check-fail-${var.name}-${aws_instance.this.id}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "StatusCheckFailed"
  namespace                 = "AWS/EC2"
  period                    = "300" #seconds
  statistic                 = "Average"
  threshold                 = "0.99"
  alarm_description         = "This metric monitors ec2 fail"
  insufficient_data_actions = []
  dimensions                = { InstanceId = aws_instance.this.id }
  alarm_actions = ["arn:aws:sns:us-east-2:579010345876:mautic-alert"]
}

resource "aws_dlm_lifecycle_policy" "this" {
  description        = "${var.name} DLM lifecycle policy"
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
        Name = var.name
      }

      copy_tags = false
    }

    target_tags = {
      Name = var.name
    }
  }
}
