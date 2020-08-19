## Module: cloudposse/terraform-aws-lambda-elasticsearch-cleanup

This module creates a scheduled Lambda function which will delete old  
Elasticsearch indexes using SigV4Auth authentication. The lambda  
function can optionally send output to an SNS topic if the topic ARN  
is given

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | ~> 2.0 |
| null | ~> 2.0 |
| template | ~> 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | ~> 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| artifact\_url | URL template for the remote artifact | `string` | `"https://artifacts.cloudposse.com/$${module_name}/$${git_ref}/$${filename}"` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| delete\_after | Number of days to preserve | `number` | `15` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | `string` | `"-"` | no |
| enabled | This module will not create any resources unless enabled is set to "true" | `bool` | `true` | no |
| es\_domain\_arn | The Elasticsearch domain ARN | `string` | n/a | yes |
| es\_endpoint | The Elasticsearch endpoint for the Lambda function to connect to | `string` | n/a | yes |
| es\_security\_group\_id | The Elasticsearch cluster security group ID | `string` | n/a | yes |
| index | Index/indices to process. Use a comma-separated list. Specify `all` to match every index except for `.kibana` or `.kibana_1` | `string` | `"all"` | no |
| index\_format | Combined with 'index' variable and is used to evaluate the index age | `string` | `"%Y.%m.%d"` | no |
| index\_regex | Determines regex that is used for matching index name and index date. By default it match two groups separated by hyphen. | `string` | `"([^-]+)-(.*)"` | no |
| name | Solution name, e.g. 'app' or 'cluster' | `string` | `"app"` | no |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | `string` | `""` | no |
| python\_version | The Python version to use | `string` | `"2.7"` | no |
| schedule | CloudWatch Events rule schedule using cron or rate expression | `string` | `"cron(0 3 * * ? *)"` | no |
| sns\_arn | SNS ARN to publish alerts | `string` | `""` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | `string` | `""` | no |
| subnet\_ids | Subnet IDs | `list(string)` | n/a | yes |
| tags | Additional tags (e.g. `map('BusinessUnit','XYZ')` | `map(string)` | `{}` | no |
| timeout | Timeout for Lambda function in seconds | `number` | `300` | no |
| vpc\_id | The VPC ID for the Lambda function | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| lambda\_function\_arn | ARN of the Lambda Function |
| lambda\_function\_source\_code\_size | The size in bytes of the function .zip file |
| security\_group\_id | Security Group ID of the Lambda Function |

