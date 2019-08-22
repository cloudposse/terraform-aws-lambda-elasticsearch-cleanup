## Module: cloudposse/terraform-aws-lambda-elasticsearch-cleanup

This module creates a scheduled Lambda function which will delete old
Elasticsearch indexes using SigV4Auth authentication. The lambda
function can optionally send output to an SNS topic if the topic ARN
is given

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| delete_after | Number of days to preserve | string | `15` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `-` | no |
| enabled | This module will not create any resources unless enabled is set to "true" | string | `true` | no |
| es_domain_arn | The Elasticsearch domain ARN | string | - | yes |
| es_endpoint | The Elasticsearch endpoint for the Lambda function to connect to | string | - | yes |
| es_security_group_id | The Elasticsearch cluster security group ID | string | - | yes |
| index | Index/indices to process. Use a comma-separated list. Specify `all` to match every index except for `.kibana` | string | `all` | no |
| index_format | Combined with 'index' variable and is used to evaluate the index age | string | `%Y.%m.%d` | no |
| name | Solution name, e.g. 'app' or 'cluster' | string | `app` | no |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | string | - | yes |
| python_version | The Python version to use | string | `2.7` | no |
| schedule | CloudWatch Events rule schedule using cron or rate expression | string | `cron(0 3 * * ? *)` | no |
| sns_arn | SNS ARN to publish alerts | string | `` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | - | yes |
| subnet_ids | Subnet ids | list | - | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | map | `<map>` | no |
| timeout | Timeout for Lambda function in seconds | string | `300` | no |
| vpc_id | The VPC ID for the Lambda function | string | - | yes |

## Outputs

| Name | Description |
|------|-------------|
| security_group_id | Security Group ID of the Lambda |

