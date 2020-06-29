variable "namespace" {
  type        = string
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
  default     = ""
}

variable "stage" {
  type        = string
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
  default     = ""
}

variable "name" {
  type        = string
  default     = "app"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = string
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = list(string)
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "enabled" {
  type        = bool
  default     = true
  description = "This module will not create any resources unless enabled is set to \"true\""
}

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

variable "index" {
  type        = string
  default     = "all"
  description = "Index/indices to process. Use a comma-separated list. Specify `all` to match every index except for `.kibana` or `.kibana_1`"
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

variable "index_regex" {
  type        = string
  default     = "([^-]+)-(.*)"
  description = "Determines regex that is used for matching index name and index date. By default it match two groups separated by hyphen."
}

variable "python_version" {
  type        = string
  default     = "2.7"
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
