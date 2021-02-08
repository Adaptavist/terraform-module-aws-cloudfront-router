// TAGGING
variable "namespace" {
  type        = string
  description = "The namespace of the distribution."
}

variable "stage" {
  type        = string
  description = "The stage of the distribution - (dev, staging etc)."
}

variable "name" {
  type        = string
  description = "The name of the distribution."
}

variable "tags" {
  type        = map(any)
  description = "Tags applied to the distribution, these should follow what is defined [here](https://github.com/Adaptavist/terraform-compliance/blob/master/features/tags.feature)."
}


variable "origin_mappings" {
  type = map(object({
    origin_id       = string
    domain_name     = string
    path_pattern    = string
    allowed_methods = list(string)
  }))
  description = "Origin mappings, origins are matched based on path"
}


variable "default_cache_behavior" {
  type = object({
    origin_id       = string
    domain_name     = string
    allowed_methods = list(string)
  })
  description = "Default behaviour of the disctrobution when a path has not been matched"
}

variable "aliases" {
  type        = list(string)
  description = "Aliases used by the CloudFront distribution. If none are set the supplied domain is used as the alias"
  default     = []
}

variable "default_root_object" {
  type        = string
  default     = "index.html"
  description = "Default root object for the CloudFront distribution, this defaults to 'index.html'."
}

variable "viewer_protocol_policy" {
  type        = string
  default     = "redirect-to-https"
  description = "Default viewer_protocol_policy for the CloudFront distribution, this defaults to 'redirect-to-https'."
}

variable "origin_protocol_policy" {
  type        = string
  default     = "https-only"
  description = "Default origin_protocol_policy for the CloudFront distribution, this defaults to 'https-only'."
}

variable "acm_cert_arn" {
  type        = string
  description = "AWS ACM certificate ARN to use for the CloudFront distribution."
}

variable "forward_all" {
  type        = bool
  default     = true
  description = "When enabled, forwards cookies, query strings and headers to origins"
}

variable "r53_zone_name" {
  type        = string
  description = "Name of the public hosted zone, this is used for creating the A record for the CloudFront distro."
}

variable "domain" {
  type        = string
  description = "Domain name to use for the CloudFront distribution."
}


variable "enable_access_logs" {
  type        = bool
  default     = false
  description = "Should accesses to the CloudFront distribution be logged, defaults to false."
}

variable "log_cookies" {
  type        = bool
  default     = false
  description = "If access logs are enabled, are cookies logged."
}
variable "access_logs_bucket" {
  type        = string
  default     = ""
  description = "If access logs are enabled the bucket the logs should go into, defaults to false."
}
