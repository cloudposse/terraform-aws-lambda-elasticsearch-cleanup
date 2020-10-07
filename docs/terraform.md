<!-- markdownlint-disable -->
## Module: cloudposse/terraform-aws-lambda-elasticsearch-cleanup

This module creates a scheduled Lambda function which will delete old  
Elasticsearch indexes using SigV4Auth authentication. The lambda  
function can optionally send output to an SNS topic if the topic ARN  
is given

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12.0 |
| aws | >= 2.0 |
| null | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| additional\_tag\_map | Additional tags for appending to tags\_as\_list\_of\_maps. Not added to `tags`. | `map(string)` | `{}` | no |
| artifact\_url | URL template for the remote artifact | `string` | `"https://artifacts.cloudposse.com/$${module_name}/$${git_ref}/$${filename}"` | no |
| attributes | Additional attributes (e.g. `1`) | `list(string)` | `[]` | no |
| context | Single object for setting entire context at once.<br>See description of individual variables for details.<br>Leave string and numeric variables as `null` to use default value.<br>Individual variable settings (non-null) override settings in context object,<br>except for attributes, tags, and additional\_tag\_map, which are merged. | <pre>object({<br>    enabled             = bool<br>    namespace           = string<br>    environment         = string<br>    stage               = string<br>    name                = string<br>    delimiter           = string<br>    attributes          = list(string)<br>    tags                = map(string)<br>    additional_tag_map  = map(string)<br>    regex_replace_chars = string<br>    label_order         = list(string)<br>    id_length_limit     = number<br>  })</pre> | <pre>{<br>  "additional_tag_map": {},<br>  "attributes": [],<br>  "delimiter": null,<br>  "enabled": true,<br>  "environment": null,<br>  "id_length_limit": null,<br>  "label_order": [],<br>  "name": null,<br>  "namespace": null,<br>  "regex_replace_chars": null,<br>  "stage": null,<br>  "tags": {}<br>}</pre> | no |
| delete\_after | Number of days to preserve | `number` | `15` | no |
| delimiter | Delimiter to be used between `namespace`, `environment`, `stage`, `name` and `attributes`.<br>Defaults to `-` (hyphen). Set to `""` to use no delimiter at all. | `string` | `null` | no |
| enabled | Set to false to prevent the module from creating any resources | `bool` | `null` | no |
| environment | Environment, e.g. 'uw2', 'us-west-2', OR 'prod', 'staging', 'dev', 'UAT' | `string` | `null` | no |
| es\_domain\_arn | The Elasticsearch domain ARN | `string` | n/a | yes |
| es\_endpoint | The Elasticsearch endpoint for the Lambda function to connect to | `string` | n/a | yes |
| es\_security\_group\_id | The Elasticsearch cluster security group ID | `string` | n/a | yes |
| id\_length\_limit | Limit `id` to this many characters.<br>Set to `0` for unlimited length.<br>Set to `null` for default, which is `0`.<br>Does not affect `id_full`. | `number` | `null` | no |
| index\_format | Combined with 'index' variable and is used to evaluate the index age | `string` | `"%Y.%m.%d"` | no |
| index\_re | Regular Expression that matches the index names to clean up (not including trailing dash and date) | `string` | `".*"` | no |
| label\_order | The naming order of the id output and Name tag.<br>Defaults to ["namespace", "environment", "stage", "name", "attributes"].<br>You can omit any of the 5 elements, but at least one must be present. | `list(string)` | `null` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | `string` | `null` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | `string` | `null` | no |
| python\_version | The Python version to use | `string` | `"3.7"` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`.<br>If not set, `"/[^a-zA-Z0-9-]/"` is used to remove all characters other than hyphens, letters and digits. | `string` | `null` | no |
| schedule | CloudWatch Events rule schedule using cron or rate expression | `string` | `"cron(0 3 * * ? *)"` | no |
| skip\_index\_re | Regular Expression that matches the index names to ignore (not clean up). Takes precedence over `index_re`.<br>\*\*\*Default is actually\*\*\* `^\\.kibana` but the README generator has issues. | `string` | `null` | no |
| sns\_arn | SNS ARN to publish alerts | `string` | `""` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', OR 'source', 'build', 'test', 'deploy', 'release' | `string` | `null` | no |
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

<!-- markdownlint-restore -->
