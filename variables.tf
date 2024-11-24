variable "managed_instances" {
  description = "Map defining instances to be managed, their tags, and schedules"
  type = map(object({
    tags = map(string) # Key-value tags for instance identification
    schedule = object({
      start = string # Cron schedule for starting the instance
      stop  = string # Cron schedule for stopping the instance
    })
  }))
}

variable "name_prefix" {
  description = "Prefix for resources created by the module"
  type        = string
}
