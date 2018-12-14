/**
* ## Module: cloudposse/terraform-aws-lambda-elasticsearch-cleanup
*
* This module creates a scheduled Lambda function which will delete old
* Elasticsearch indexes using SigV4Auth authentication. The lambda 
* function can optionally send output to an SNS topic if the topic ARN
* is given
*/

# Terraform
#--------------------------------------------------------------
terraform {
  required_version = ">= 0.10.2"
}

# Data
#--------------------------------------------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
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
      "es:List*",
    ]

    effect = "Allow"

    resources = [
      "${var.es_domain_arn}",
    ]
  }
}

# Modules
#--------------------------------------------------------------
module "label" {
  source     = "git::https://github.com/cloudposse/terraform-terraform-label.git?ref=tags/0.2.1"
  namespace  = "${var.namespace}"
  name       = "${var.name}"
  stage      = "${var.stage}"
  delimiter  = "${var.delimiter}"
  attributes = "${compact(concat(var.attributes, list("elasticsearch", "cleanup")))}"
  tags       = "${var.tags}"
  enabled    = "true"
}

# Locals
#--------------------------------------------------------------
locals {
  function_name = "${module.label.id}"
}

# Resources
#--------------------------------------------------------------
resource "aws_lambda_function" "default" {
  filename         = "${module.artifact.file}"
  function_name    = "${local.function_name}"
  description      = "${local.function_name}"
  timeout          = "${var.timeout}"
  runtime          = "python${var.python_version}"
  role             = "${aws_iam_role.default.arn}"
  handler          = "es-cleanup.lambda_handler"
  source_code_hash = "${base64sha256(file(local.lambda_path))}"
  tags             = "${module.label.tags}"

  environment {
    variables = {
      es_endpoint  = "${var.es_endpoint}"
      index        = "${var.index}"
      delete_after = "${var.delete_after}"
      index_format = "${var.index_format}"
      sns_arn      = "${var.sns_arn}"
    }
  }

  vpc_config {
    subnet_ids         = ["${var.subnet_ids}"]
    security_group_ids = ["${aws_security_group.default.id}"]
  }
}

resource "aws_security_group" "default" {
  name        = "${local.function_name}"
  description = "${local.function_name}"
  vpc_id      = "${var.vpc_id}"
  tags        = "${module.label.tags}"
}

resource "aws_security_group_rule" "egress_from_lambda_to_es_cluster" {
  description              = "Allow outbound traffic from Lambda Elasticsearch cleanup SG to Elasticsearch SG"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${var.es_security_group_id}"
  security_group_id        = "${aws_security_group.default.id}"
}

resource "aws_security_group_rule" "ingress_to_es_cluster_from_lambda" {
  description              = "Allow inbound traffic to Elasticsearch domain from Lambda Elasticsearch cleanup SG"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.default.id}"
  security_group_id        = "${var.es_security_group_id}"
}

resource "aws_iam_role" "default" {
  name               = "${local.function_name}"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
  tags               = "${module.label.tags}"
}

resource "aws_iam_role_policy" "default" {
  name   = "${local.function_name}"
  role   = "${aws_iam_role.default.name}"
  policy = "${data.aws_iam_policy_document.default.json}"
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = "${aws_iam_role.default.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_cloudwatch_event_rule" "default" {
  name                = "${local.function_name}"
  description         = "${local.function_name}"
  schedule_expression = "${var.schedule}"
}

resource "aws_lambda_permission" "default" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.default.arn}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.default.arn}"
}

resource "aws_cloudwatch_event_target" "default" {
  target_id = "${local.function_name}"
  rule      = "${aws_cloudwatch_event_rule.default.name}"
  arn       = "${aws_lambda_function.default.arn}"
}
