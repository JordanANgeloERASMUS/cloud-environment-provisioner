variable "aws_region" {
  description = "AWS region for the S3 bucket and budget. CloudFront is global."
  type        = string
  default     = "us-east-1"
}

variable "site_bucket_name" {
  description = "Globally unique S3 bucket name for the private site origin."
  type        = string

  validation {
    condition = (
      length(var.site_bucket_name) >= 3 &&
      length(var.site_bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", var.site_bucket_name)) &&
      !strcontains(var.site_bucket_name, "..") &&
      !strcontains(var.site_bucket_name, ".-") &&
      !strcontains(var.site_bucket_name, "-.") &&
      !can(regex("^[0-9]{1,3}(\\.[0-9]{1,3}){3}$", var.site_bucket_name)) &&
      !startswith(var.site_bucket_name, "xn--") &&
      !startswith(var.site_bucket_name, "sthree-") &&
      !startswith(var.site_bucket_name, "amzn-s3-demo-") &&
      !endswith(var.site_bucket_name, "-s3alias") &&
      !endswith(var.site_bucket_name, "--ol-s3") &&
      !endswith(var.site_bucket_name, ".mrap") &&
      !endswith(var.site_bucket_name, "--x-s3") &&
      !endswith(var.site_bucket_name, "--table-s3")
    )
    error_message = "Use a 3-63 character lowercase S3 bucket name with letters, numbers, dots, or hyphens; it must start and end with a letter or number and avoid reserved prefixes/suffixes, IP-address formatting, and adjacent dots or period-hyphen pairs."
  }
}

variable "project_name" {
  description = "Project name applied to resource tags."
  type        = string
  default     = "cloud-environment-provisioner"
}

variable "environment" {
  description = "Environment name applied to resource tags."
  type        = string
  default     = "demo"

  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "Environment must not be empty."
  }
}

variable "tags" {
  description = "Additional tags applied to supported resources."
  type        = map(string)
  default     = {}
}

variable "enable_budget" {
  description = "Create an optional monthly AWS cost budget with email alerts."
  type        = bool
  default     = false
}

variable "monthly_budget_limit" {
  description = "Monthly budget threshold in USD when enable_budget is true."
  type        = number
  default     = 5

  validation {
    condition     = var.monthly_budget_limit > 0
    error_message = "Monthly budget limit must be greater than zero."
  }
}

variable "budget_notification_email" {
  description = "Email for budget alerts; required only when enable_budget is true."
  type        = string
  default     = ""

  validation {
    condition = (
      !var.enable_budget ||
      can(regex("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$", var.budget_notification_email))
    )
    error_message = "Set a valid budget_notification_email when enable_budget is true."
  }
}
