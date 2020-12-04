/*
  Test Fixture
*/

terraform {
  backend "s3" {
    bucket         = "product-sandbox-terraform-state-management"
    dynamodb_table = "product-sandbox-terraform-state-management"
    region         = "us-east-1"
    encrypt        = "true"
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  default_allowed_methods = ["HEAD", "GET", "OPTIONS"]
  tld                     = "avst-sbx.adaptavist.com"
  domain                  = "${random_string.random.result}-cf-router-test.${local.tld}"
  namespace               = "tf-tests"
  stage                   = "test"
  name                    = "cf-router"
  tags = {
    "Avst:BusinessUnit" : "platform"
    "Avst:Team" : "cloud-infra"
    "Avst:CostCenter" : "foo"
    "Avst:Project" : "foo"
    "Avst:Stage:Type" : "sandbox"
  }
}

data "aws_acm_certificate" "cert" {
  domain   = "*.${local.tld}"
  statuses = ["ISSUED"]
}

data "aws_route53_zone" "zone" {
  name         = local.tld
  private_zone = false
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

module cf_distro {
  source = "../../"
    
  aliases    = [local.domain]

  namespace = local.namespace
  stage     = local.stage
  name      = local.name
  tags      = local.tags

  acm_cert_arn = data.aws_acm_certificate.cert.arn

  default_cache_behavior = {
    origin_id       = "bbc"
    domain_name     = "www.bbc.co.uk"
    allowed_methods = local.default_allowed_methods
  }

  origin_mappings = {
    scriptrunner = {
      origin_id       = "scriptrunner"
      domain_name     = "scriptrunner.adaptavist.com"
      path_pattern    = "/latest/*"
      allowed_methods = local.default_allowed_methods
    }
    bbc = {
      origin_id       = "bbc"
      domain_name     = "www.bbc.co.uk"
      path_pattern    = "/news/*"
      allowed_methods = local.default_allowed_methods
    }

  }
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = local.domain
  type    = "A"

  alias {
    name                   = module.cf_distro.cf_domain_name
    zone_id                = module.cf_distro.cf_hosted_zone_id
    evaluate_target_health = false
  }
}
