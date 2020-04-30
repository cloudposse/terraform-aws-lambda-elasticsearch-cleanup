region = "us-east-2"

namespace = "eg"

stage = "test"

name = "es-cleanup"

availability_zones = ["us-east-1a", "us-east-1b"]

instance_type = "t2.small.elasticsearch"

elasticsearch_version = "7.4"

instance_count = 2

zone_awareness_enabled = true

encrypt_at_rest_enabled = false

dedicated_master_enabled = false

kibana_subdomain_name = "kibana-es-cleanup"

ebs_volume_size = 10

create_iam_service_linked_role = false

dns_zone_id = "Z3SO0TKDDQ0RGG"

schedule = "rate(5 minutes)"

artifact_url = "https://artifacts.cloudposse.com/terraform-external-module-artifact/example/test.zip"
