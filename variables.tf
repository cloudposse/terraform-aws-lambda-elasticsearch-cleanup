variable "es_endpoint" {
  type        = string
  description = "The Elasticsearch endpoint for the Lambda function to connect to"
}

variable "es_domain_arn" {
  type        = string
  description = "The Elasticsearch domain ARN"
}

variable "es_security_group_id" {
  type        = string
  description = "The Elasticsearch cluster security group ID"
}

variable "schedule" {
  type        = string
  default     = "cron(0 3 * * ? *)"
  description = "CloudWatch Events rule schedule using cron or rate expression"
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID for the Lambda function"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs"
}

variable "sns_arn" {
  type        = string
  default     = ""
  description = "SNS ARN to publish alerts"
}

variable "delete_after" {
  type        = number
  default     = 15
  description = "Number of days to preserve"
}

variable "index_format" {
  type        = string
  default     = "%Y.%m.%d"
  description = "Combined with 'index' variable and is used to evaluate the index age"
}

variable "index_re" {
  type        = string
  default     = ".*"
  description = "Regular Expression that matches the index names to clean up (not including trailing dash and date)"
}

variable "skip_index_re" {
  type = string
  #default     = "^\\.kibana*"
  default     = null
  description = <<-EOT
    Regular Expression that matches the index names to ignore (not clean up). Takes precedence over `index_re`.
    ***Default is actually*** `^\\.kibana` but the README generator has issues.
    EOT
}

variable "python_version" {
  type        = string
  default     = "3.7"
  description = "The Python version to use"
}

variable "timeout" {
  type        = number
  default     = 300
  description = "Timeout for Lambda function in seconds"
}

variable "artifact_url" {
  type        = string
  description = "URL template for the remote artifact"
  default     = "https://artifacts.cloudposse.com/$$${module_name}/$$${git_ref}/$$${filename}"
}
