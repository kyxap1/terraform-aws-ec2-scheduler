
# EC2 Scheduler Terraform Module

This Terraform module provides an automated way to manage the start and stop schedules for EC2 instances using AWS EventBridge and Systems Manager Automation.

## Features

- Dynamically schedules start and stop times for EC2 instances based on user-defined tags and cron expressions.
- Automatically creates IAM roles and policies for EventBridge and Systems Manager Automation.
- Supports multiple instances with different schedules and tag configurations.

## Usage

```hcl
module "ec2_scheduler" {
  source      = "./modules/ec2_scheduler"
  name_prefix = "example-scheduler"

  managed_instances = {
    instance1 = {
      tags = {
        Name = "dev-ec2-instance"
        Role = "webserver"
      }
      schedule = {
        start = "0 6 * * *"  # Start at 6:00 AM UTC
        stop  = "0 22 * * *" # Stop at 10:00 PM UTC
      }
    }
    instance2 = {
      tags = {
        Environment = "staging"
        Owner       = "team-x"
      }
      schedule = {
        start = "0 5 * * *"  # Start at 5:00 AM UTC
        stop  = "0 21 * * *" # Stop at 9:00 PM UTC
      }
    }
  }
}
```

## Inputs

| Name               | Description                                             | Type   | Default | Required |
|--------------------|---------------------------------------------------------|--------|---------|----------|
| `name_prefix`      | Prefix for resource names                               | string | n/a     | yes      |
| `managed_instances`| Map of instance configurations including tags and schedule | map(object) | n/a | yes      |

## Outputs

| Name                       | Description                                      |
|----------------------------|--------------------------------------------------|
| `ssm_automation_role_arn`  | ARN of the IAM role for SSM Automation           |
| `stop_schedule_rule_arns`  | Map of ARNs for EventBridge stop schedule rules  |
| `start_schedule_rule_arns` | Map of ARNs for EventBridge start schedule rules |
| `stop_schedule_target_arns`| Map of ARNs for EventBridge stop schedule targets|
| `start_schedule_target_arns`| Map of ARNs for EventBridge start schedule targets|

## Notes

- Ensure that the EC2 instances you wish to manage are tagged appropriately.
- All cron expressions in this example use **UTC** time.
- For time zone conversions, refer to tools like [crontab.guru](https://crontab.guru).

## Authors

Module is maintained by [Oleksandr Kukhar](https://github.com/kyxap1)

## License

Apache 2 Licensed. See LICENSE for full details.
