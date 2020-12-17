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
    "Avst:Stage:Name" : "sandbox"
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

  aliases = [local.domain]

  namespace = local.namespace
  stage     = local.stage
  name      = local.name
  tags      = local.tags
  forward_all = false

  acm_cert_arn = data.aws_acm_certificate.cert.arn
  domain = local.domain
  r53_zone_name = local.tld

  default_cache_behavior = {
    origin_id       = "docs"
    domain_name     = "scriptrunner.adaptavist.com"
    allowed_methods = local.default_allowed_methods
  }
  origin_mappings = {
    scriptrunner = {
      origin_id       = "scriptrunner"
      domain_name     = "scriptrunner.connect.adaptavist.com"
      path_pattern    = "/sr-dispatcher/jira/*"
      allowed_methods = local.default_allowed_methods
    }
    docs = {
      origin_id       = "docs"
      domain_name     = "scriptrunner.adaptavist.com"
      path_pattern    = "/latest/*"
      allowed_methods = local.default_allowed_methods
    }
    assets = {
      origin_id       = "sr-assets"
      domain_name     = "assets.sr-cloud.connect.adaptavistlabs.com"
      path_pattern    = "/public/*"
      allowed_methods = local.default_allowed_methods
    }
  }
}


