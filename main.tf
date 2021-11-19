/**
* ## Module: cloudposse/terraform-aws-lambda-elasticsearch-cleanup
*
* This module creates a scheduled Lambda function which will delete old
* Elasticsearch indexes using SigV4Auth authentication. The lambda
* function can optionally send output to an SNS topic if the topic ARN
* is given
*/

# Data
#--------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  count = local.enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "es_logs" {
  count = local.enabled ? 1 : 0

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"

    resources = ["*"]
  }

  statement {
    actions = [
      "es:ESHttpGet",
      "es:ESHttpPut",
      "es:ESHttpPost",
      "es:ESHttpHead",
      "es:ESHttpDelete",
      "es:Describe*",
      "es:List*"
    ]

    effect = "Allow"

    resources = [
      "${var.es_domain_arn}/*",
    ]
  }
}

data "aws_iam_policy_document" "sns" {
  count = local.enabled ? 1 : 0

  statement {
    actions = [
      "sns:Publish"
    ]

    effect = "Allow"

    resources = [
      var.sns_arn
    ]
  }
}

data "aws_iam_policy_document" "default" {
  count = local.enabled ? 1 : 0

  source_json   = join("", data.aws_iam_policy_document.es_logs.*.json)
  override_json = length(var.sns_arn) > 0 ? join("", data.aws_iam_policy_document.sns.*.json) : "{}"
}

locals {
  enabled       = module.this.enabled
  skip_index_re = var.skip_index_re == null ? "^\\.kibana*" : var.skip_index_re
}

# Modules
#--------------------------------------------------------------
module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  attributes = compact(concat(module.this.attributes, ["elasticsearch", "cleanup"]))

  context = module.this.context
}

module "artifact" {
  source      = "cloudposse/module-artifact/external"
  version     = "0.7.1"
  enabled     = module.this.enabled
  filename    = "lambda.zip"
  module_name = "terraform-aws-lambda-elasticsearch-cleanup"
  module_path = path.module
  git_ref     = var.artifact_git_ref
  url         = var.artifact_url
}

# Locals
#--------------------------------------------------------------
locals {
  function_name = module.label.id
}

# Resources
#--------------------------------------------------------------
resource "aws_lambda_function" "default" {
  count            = local.enabled ? 1 : 0
  filename         = module.artifact.file
  function_name    = local.function_name
  description      = local.function_name
  timeout          = var.timeout
  runtime          = "python${var.python_version}"
  role             = join("", aws_iam_role.default.*.arn)
  handler          = "es-cleanup.lambda_handler"
  source_code_hash = module.artifact.base64sha256
  tags             = module.label.tags

  environment {
    variables = {
      delete_after = var.delete_after
      es_endpoint  = var.es_endpoint
      index        = var.index_re
      skip_index   = local.skip_index_re
      index_format = var.index_format
      sns_arn      = var.sns_arn
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [join("", aws_security_group.default.*.id)]
  }
}

resource "aws_security_group" "default" {
  count       = local.enabled ? 1 : 0
  name        = local.function_name
  description = local.function_name
  vpc_id      = var.vpc_id
  tags        = module.label.tags
}

resource "aws_security_group_rule" "udp_dns_egress_from_lambda" {
  count             = local.enabled ? 1 : 0
  description       = "Allow outbound UDP traffic from Lambda Elasticsearch cleanup to DNS"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "tcp_dns_egress_from_lambda" {
  count             = local.enabled ? 1 : 0
  description       = "Allow outbound TCP traffic from Lambda Elasticsearch cleanup to DNS"
  type              = "egress"
  from_port         = 53
  to_port           = 53
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "egress_from_lambda_to_es_cluster" {
  count                    = local.enabled ? 1 : 0
  description              = "Allow outbound traffic from Lambda Elasticsearch cleanup SG to Elasticsearch SG"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = var.es_security_group_id
  security_group_id        = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "ingress_to_es_cluster_from_lambda" {
  count                    = local.enabled ? 1 : 0
  description              = "Allow inbound traffic to Elasticsearch domain from Lambda Elasticsearch cleanup SG"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = join("", aws_security_group.default.*.id)
  security_group_id        = var.es_security_group_id
}

resource "aws_iam_role" "default" {
  count              = local.enabled ? 1 : 0
  name               = local.function_name
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  tags               = module.label.tags
}

resource "aws_iam_role_policy" "default" {
  count  = local.enabled ? 1 : 0
  name   = local.function_name
  role   = join("", aws_iam_role.default.*.name)
  policy = join("", data.aws_iam_policy_document.default.*.json)
}

resource "aws_iam_role_policy_attachment" "default" {
  count      = local.enabled ? 1 : 0
  role       = join("", aws_iam_role.default.*.name)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_event_rule" "default" {
  count               = local.enabled ? 1 : 0
  name                = local.function_name
  description         = local.function_name
  schedule_expression = var.schedule
}

resource "aws_lambda_permission" "default" {
  count         = local.enabled ? 1 : 0
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = join("", aws_lambda_function.default.*.arn)
  principal     = "events.amazonaws.com"
  source_arn    = join("", aws_cloudwatch_event_rule.default.*.arn)
}

resource "aws_cloudwatch_event_target" "default" {
  count     = local.enabled ? 1 : 0
  target_id = local.function_name
  rule      = join("", aws_cloudwatch_event_rule.default.*.name)
  arn       = join("", aws_lambda_function.default.*.arn)
}
