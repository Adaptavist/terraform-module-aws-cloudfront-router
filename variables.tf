variable "namespace" {
  type = string
}

variable "stage" {
  type = string
}

variable "name" {
  type = string
}

variable "tags" {
  type = map
}

variable "origin_mappings" {
  type = map(object({
    origin_id       = string
    domain_name     = string
    path_pattern    = string
    allowed_methods = list(string)
  }))
}


variable "default_cache_behavior" {
  type = object({
    origin_id       = string
    domain_name     = string
    allowed_methods = list(string)
  })
}

variable "aliases" {
  type = list(string)
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}

variable "viewer_protocol_policy" {
  type    = string
  default = "redirect-to-https"
}

variable "origin_protocol_policy" {
  type    = string
  default = "https-only"
}

variable "acm_cert_arn" {
  type = string
}

variable "forward_all" {
  type = bool
  default = true
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
