# module-aws-cloudfront-router

A module which creates a CloudFront distribution which is used for routing requests to backend origins based on paths. The requests are not cached. 

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:-----:|
| acm\_cert\_arn | AWS ACM certificate ARN to use for the CloudFront distribution. | `string` | n/a | yes |
| aliases | Aliases used by the CloudFront distribution. | `list(string)` | n/a | yes |
| default\_cache\_behavior | Default behaviour of the disctrobution when a path has not been matched | <pre>object({<br>    origin_id       = string<br>    domain_name     = string<br>    allowed_methods = list(string)<br>  })</pre> | n/a | yes |
| default\_root\_object | Default root object for the CloudFront distribution, this defaults to 'index.html'. | `string` | `"index.html"` | no |
| domain | Domain name to use for the CloudFront distribution. | `string` | n/a | yes |
| forward\_all | When enabled, forwards cookies, query strings and headers to origins | `bool` | `true` | no |
| name | The name of the distribution. | `string` | n/a | yes |
| namespace | The namespace of the distribution. | `string` | n/a | yes |
| origin\_mappings | Origin mappings, origins are matched based on path | <pre>map(object({<br>    origin_id       = string<br>    domain_name     = string<br>    path_pattern    = string<br>    allowed_methods = list(string)<br>  }))</pre> | n/a | yes |
| origin\_protocol\_policy | Default origin\_protocol\_policy for the CloudFront distribution, this defaults to 'https-only'. | `string` | `"https-only"` | no |
| r53\_zone\_name | Name of the public hosted zone, this is used for creating the A record for the CloudFront distro. | `string` | n/a | yes |
| stage | The stage of the distribution - (dev, staging etc). | `string` | n/a | yes |
| tags | Tags applied to the distribution, these should follow what is defined [here](https://github.com/Adaptavist/terraform-compliance/blob/master/features/tags.feature). | `map` | n/a | yes |
| viewer\_protocol\_policy | Default viewer\_protocol\_policy for the CloudFront distribution, this defaults to 'redirect-to-https'. | `string` | `"redirect-to-https"` | no |


# origin_mappings object
| Name                        | Description                                                                                     |
| --------------------------- | ----------------------------------------------------------------------------------------------- |
| origin_id                 | The user defined unique id of the origin                                      |
| domain_name | The domain name of the origin |
| path_pattern | The path which matches this origin |
| allowed_methods | A list containing which HTTP methods CloudFront processes and forwards to the backend origin |


# default_cache_behavior
| Name                        | Description                                                                                     |
| --------------------------- | ----------------------------------------------------------------------------------------------- |
| origin_id                 | The user defined unique id of the origin                                      |
| domain_name | The domain name of the origin |
| allowed_methods | A list containing which HTTP methods CloudFront processes and forwards to the backend origin |


## Outputs

| Name | Description |
|------|-------------|
| cf\_arn | ARN of AWS CloudFront distribution |
| cf\_domain\_name | Domain name corresponding to the distribution |
| cf\_etag | Current version of the distribution's information |
| cf\_hosted\_zone\_id | CloudFront Route 53 zone ID |
| cf\_id | ID of AWS CloudFront distribution |
| cf\_status | Current status of the distribution |

