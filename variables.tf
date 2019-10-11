variable "enabled" {
  type        = "string"
  default     = "true"
  description = "This module will not create any resources unless enabled is set to \"true\""
}

variable "es_endpoint" {
  type        = "string"
  description = "The Elasticsearch endpoint for the Lambda function to connect to"
}

variable "es_domain_arn" {
  type        = "string"
  description = "The Elasticsearch domain ARN"
}

variable "es_security_group_id" {
  type        = "string"
  description = "The Elasticsearch cluster security group ID"
}

variable "schedule" {
  type        = "string"
  default     = "cron(0 3 * * ? *)"
  description = "CloudWatch Events rule schedule using cron or rate expression"
}

variable "subnet_ids" {
  type        = "list"
  description = "Subnet ids"
}

variable "sns_arn" {
  type        = "string"
  default     = ""
  description = "SNS ARN to publish alerts"
}

variable "index" {
  type        = "string"
  default     = "all"
  description = "Index/indices to process. Use a comma-separated list. Specify `all` to match every index except for `.kibana` or `.kibana_1`"
}

variable "delete_after" {
  default     = 15
  description = "Number of days to preserve"
}

variable "namespace" {
  type        = "string"
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = "string"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = "string"
  default     = "app"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `namespace`, `stage`, `name` and `attributes`"
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit','XYZ')`"
}

variable "index_format" {
  default     = "%Y.%m.%d"
  description = "Combined with 'index' variable and is used to evaluate the index age"
}

variable "python_version" {
  type        = "string"
  default     = "2.7"
  description = "The Python version to use"
}

variable "timeout" {
  default     = 300
  description = "Timeout for Lambda function in seconds"
}

variable "vpc_id" {
  type        = "string"
  description = "The VPC ID for the Lambda function"
}
