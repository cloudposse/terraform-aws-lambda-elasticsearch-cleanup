region = "us-east-2"

namespace = "eg"

stage = "test"

name = "es-cleanup"

availability_zones = ["us-east-2a"]

instance_type = "t3.small.elasticsearch"

elasticsearch_version = "7.7"

instance_count = 1

zone_awareness_enabled = false

encrypt_at_rest_enabled = false

dedicated_master_enabled = false

kibana_subdomain_name = "kibana-es-cleanup"

ebs_volume_size = 10

create_iam_service_linked_role = false

dns_zone_id = "Z3SO0TKDDQ0RGG"

schedule = "rate(5 minutes)"

artifact_url = "https://artifacts.cloudposse.com/terraform-external-module-artifact/example/test.zip"
