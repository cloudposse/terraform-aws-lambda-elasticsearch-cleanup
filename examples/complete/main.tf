provider "aws" {
  region = var.region
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "2.1.0"

  ipv4_primary_cidr_block = "172.16.0.0/16"

  context = module.this.context
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "2.4.1"

  availability_zones   = var.availability_zones
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  ipv4_cidr_block      = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false

  context = module.this.context
}

module "elasticsearch" {
  source  = "cloudposse/elasticsearch/aws"
  version = "0.44.0"

  security_groups                = [module.vpc.vpc_default_security_group_id]
  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.subnets.private_subnet_ids
  zone_awareness_enabled         = var.zone_awareness_enabled
  elasticsearch_version          = var.elasticsearch_version
  instance_type                  = var.instance_type
  instance_count                 = var.instance_count
  encrypt_at_rest_enabled        = var.encrypt_at_rest_enabled
  dedicated_master_enabled       = var.dedicated_master_enabled
  create_iam_service_linked_role = var.create_iam_service_linked_role
  domain_hostname_enabled        = var.domain_hostname_enabled
  kibana_hostname_enabled        = var.kibana_hostname_enabled
  kibana_subdomain_name          = var.kibana_subdomain_name
  ebs_volume_size                = var.ebs_volume_size
  dns_zone_id                    = var.dns_zone_id

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  context = module.this.context
}

module "elasticsearch_cleanup" {
  source = "../.."

  es_endpoint          = module.elasticsearch.domain_endpoint
  es_domain_arn        = module.elasticsearch.domain_arn
  es_security_group_id = module.elasticsearch.security_group_id
  subnet_ids           = module.subnets.private_subnet_ids
  vpc_id               = module.vpc.vpc_id
  schedule             = var.schedule
  artifact_url         = var.artifact_url

  context = module.this.context
}
