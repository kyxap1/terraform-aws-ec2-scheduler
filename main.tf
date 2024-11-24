# Data source to determine the current AWS region
data "aws_region" "current" {}

# Define locals for processing the managed_instances input
locals {
  managed_instances = {
    for instance, config in var.managed_instances :
    instance => {
      tags  = [for tag_key, tag_value in config.tags : { Key = tag_key, Value = tag_value }]
      start = config.schedule.start
      stop  = config.schedule.stop
    }
  }
}

# IAM Role for SSM Automation
resource "aws_iam_role" "ssm_automation_role" {
  name = "${var.name_prefix}-ssm-automation-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "events.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for the Role
resource "aws_iam_policy" "ssm_automation_policy" {
  name = "${var.name_prefix}-ssm-automation-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:StopInstances",
          "ec2:StartInstances",
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:StartAutomationExecution"
        ],
        Resource = "*"
      }
    ]
  })
}

# Attach the IAM Policy to the SSM Automation Role
resource "aws_iam_role_policy_attachment" "ssm_automation_policy_attachment" {
  role       = aws_iam_role.ssm_automation_role.name
  policy_arn = aws_iam_policy.ssm_automation_policy.arn
}

# EventBridge Rule to Stop Instances
resource "aws_cloudwatch_event_rule" "stop_schedule_rule" {
  for_each = local.managed_instances

  name                = "${var.name_prefix}-${each.key}-stop-schedule"
  description         = "Stop schedule for ${each.key}"
  schedule_expression = each.value.stop
}

# EventBridge Target for Stopping Instances
resource "aws_cloudwatch_event_target" "stop_target" {
  for_each = local.managed_instances

  rule     = aws_cloudwatch_event_rule.stop_schedule_rule[each.key].name
  arn      = "arn:aws:ssm:${data.aws_region.current.name}:aws:document/AWS-StopEC2Instance"
  role_arn = aws_iam_role.ssm_automation_role.arn

  input = jsonencode({
    Filters = each.value.tags
  })
}

# EventBridge Rule to Start Instances
resource "aws_cloudwatch_event_rule" "start_schedule_rule" {
  for_each = local.managed_instances

  name                = "${var.name_prefix}-${each.key}-start-schedule"
  description         = "Start schedule for ${each.key}"
  schedule_expression = each.value.start
}

# EventBridge Target for Starting Instances
resource "aws_cloudwatch_event_target" "start_target" {
  for_each = local.managed_instances

  rule     = aws_cloudwatch_event_rule.start_schedule_rule[each.key].name
  arn      = "arn:aws:ssm:${data.aws_region.current.name}:aws:document/AWS-StartEC2Instance"
  role_arn = aws_iam_role.ssm_automation_role.arn

  input = jsonencode({
    Filters = each.value.tags
  })
}
