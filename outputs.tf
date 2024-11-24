output "ssm_automation_role_arn" {
  description = "ARN of the IAM role for SSM Automation"
  value       = aws_iam_role.ssm_automation_role.arn
}

output "stop_schedule_rule_arns" {
  description = "ARNs of the stop schedule rules"
  value       = { for k, v in aws_cloudwatch_event_rule.stop_schedule_rule : k => v.arn }
}

output "start_schedule_rule_arns" {
  description = "ARNs of the start schedule rules"
  value       = { for k, v in aws_cloudwatch_event_rule.start_schedule_rule : k => v.arn }
}

output "stop_schedule_target_arns" {
  description = "ARNs of the stop schedule targets"
  value       = { for k, v in aws_cloudwatch_event_target.stop_target : k => v.arn }
}

output "start_schedule_target_arns" {
  description = "ARNs of the start schedule targets"
  value       = { for k, v in aws_cloudwatch_event_target.start_target : k => v.arn }
}
