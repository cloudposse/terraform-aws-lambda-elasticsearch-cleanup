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

module "vpc" {
  source    = "git::https://github.com/cloudposse/terraform-aws-vpc.git?ref=master"
  name      = "${var.name}"
  namespace = "${var.namespace}"
  stage     = "${var.stage}"
  tags      = "${module.label.tags}"
}

module "subnets" {
  source             = "git::https://github.com/cloudposse/terraform-aws-dynamic-subnets.git?ref=master"
  name               = "${var.name}"
  namespace          = "${var.namespace}"
  stage              = "${var.stage}"
  region             = "us-west-2"
  vpc_id             = "${module.vpc.vpc_id}"
  igw_id             = "${module.vpc.igw_id}"
  cidr_block         = "10.0.0.0/16"
  availability_zones = ["us-west-2a", "us-west-2b"]
  tags               = "${module.label.tags}"
}

module "elasticsearch" {
  source                         = "git::https://github.com/cloudposse/terraform-aws-elasticsearch.git?ref=master"
  name                           = "${var.name}"
  namespace                      = "${var.namespace}"
  stage                          = "${var.stage}"
  dns_zone_id                    = "Z3SO0TKDDQ0RGG"
  security_groups                = []
  vpc_id                         = "${module.vpc.vpc_id}"
  subnet_ids                     = ["${module.subnets.public_subnet_ids}"]
  zone_awareness_enabled         = "true"
  elasticsearch_version          = "6.3"
  instance_type                  = "t2.small.elasticsearch"
  instance_count                 = 4
  kibana_subdomain_name          = "kibana-es"
  encrypt_at_rest_enabled        = "false"
  ebs_volume_size                = 10
  iam_actions                    = ["es:*"]
  iam_role_arns                  = ["*"]
  create_iam_service_linked_role = "false"
  tags                           = "${module.label.tags}"
}

module "elasticsearch_cleanup" {
  source               = "../"
  es_endpoint          = "${module.elasticsearch.domain_endpoint}"
  es_domain_arn        = "${module.elasticsearch.domain_arn}"
  es_security_group_id = "${module.elasticsearch.security_group_id}"
  subnet_ids           = ["${module.subnets.public_subnet_ids}"]
  vpc_id               = "${module.vpc.vpc_id}"
  namespace            = "${var.namespace}"
  stage                = "${var.stage}"
  schedule             = "${var.schedule}"
  tags                 = "${module.label.tags}"
}
