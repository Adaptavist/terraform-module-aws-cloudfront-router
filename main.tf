module "labels" {
  source  = "cloudposse/label/terraform"
  version = "0.5.0"

  namespace = var.namespace
  stage     = var.stage
  name      = var.name
  tags      = var.tags
}

data "aws_route53_zone" "public_zone" {
  name         = var.r53_zone_name
  private_zone = false
}

resource "aws_cloudfront_distribution" "this" {

  dynamic "origin" {
    for_each = var.origin_mappings
    content {
      domain_name = origin.value.domain_name
      origin_id   = origin.value.origin_id

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "https-only"
        origin_ssl_protocols   = ["SSLv3", "TLSv1.2"]
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Cloudfront distribution for ${module.labels.id}"
  default_root_object = var.default_root_object

  aliases = length(var.aliases) > 0 ? var.aliases : [var.domain]

  dynamic "logging_config" {
    for_each = var.enable_access_logs ? [1] : []
    content {
      include_cookies = var.log_cookies
      bucket          = var.access_logs_bucket
      prefix          = var.domain
    }
  }

  default_cache_behavior {
    allowed_methods  = var.default_cache_behavior.allowed_methods
    target_origin_id = var.default_cache_behavior.origin_id

    viewer_protocol_policy = var.viewer_protocol_policy

    dynamic "forwarded_values" {
      for_each = var.forward_all ? [1] : []
      content {
        headers      = ["*"]
        query_string = true
        cookies {
          forward = "all"
        }
      }
    }

    dynamic "forwarded_values" {
      for_each = var.forward_all ? [] : [1]
      content {
        query_string = false
        cookies {
          forward = "none"
        }
      }
    }

    // We are using cloudfront for routing only, we dont want to cache anything.
    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
    // we have to specifiy some methods
    cached_methods = ["HEAD", "GET"]

  }

  dynamic "ordered_cache_behavior" {
    for_each = var.origin_mappings
    content {

      path_pattern     = ordered_cache_behavior.value.path_pattern
      allowed_methods  = ordered_cache_behavior.value.allowed_methods
      target_origin_id = ordered_cache_behavior.value.origin_id

      dynamic "forwarded_values" {
        for_each = var.forward_all ? [1] : []
        content {
          headers      = ["*"]
          query_string = true
          cookies {
            forward = "all"
          }
        }
      }

      dynamic "forwarded_values" {
        for_each = var.forward_all ? [] : [1]
        content {
          query_string = false
          cookies {
            forward = "none"
          }
        }
      }


      compress               = true
      viewer_protocol_policy = var.viewer_protocol_policy

      // We are using cloudfront for routing only, we dont want to cache anything.
      min_ttl     = 0
      default_ttl = 0
      max_ttl     = 0
      // we have to specifiy some methods
      cached_methods = ["HEAD", "GET"]

    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_All"

  tags = module.labels.tags

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn
    minimum_protocol_version = "TLSv1.2_2019"
    ssl_support_method       = "sni-only"
  }
}

resource "aws_route53_record" "this" {
  zone_id = data.aws_route53_zone.public_zone.zone_id
  name    = var.domain
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}
