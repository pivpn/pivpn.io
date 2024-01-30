terraform {
  required_version = ">= 1.6.1"

  backend "s3" {
    bucket = "pivpn-infra-tfstate"
    key    = "install/tfstate"
    region = "us-east-1"
  }

}

provider "aws" {
  region = "us-east-1"
}

data "aws_acm_certificate" "this" {
  domain   = "install.pivpn.io"
  statuses = ["ISSUED"]
  most_recent = true
  key_types = ["EC_prime256v1"]
}

locals {
  acm_certificate_arn = data.aws_acm_certificate.this.arn

  is_ipv6_enabled               = true
  default_root_object           = "install.sh"
  custom_origin_http_port       = 80
  custom_origin_https_port      = 443
  custom_origin_protocol_policy = "https-only"
  custom_origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
  allowed_methods               = ["GET", "HEAD"]
  cached_methods                = ["GET", "HEAD"]
  viewer_protocol_policy        = "redirect-to-https"
  min_ttl                       = 1800
  default_ttl                   = 1800
  max_ttl                       = 1800
  query_string                  = false
  forward_cookies               = "none"
  geo_restriction               = "none"
  ssl_support_method            = "sni-only"
  minimum_protocol_version      = "TLSv1.2_2021"
}


resource "aws_cloudfront_distribution" "master" {
  aliases             = ["install.pivpn.io"]
  comment             = "pivpn install script"
  enabled             = true
  is_ipv6_enabled     = local.is_ipv6_enabled
  default_root_object = local.default_root_object

  origin {
    origin_id   = "install.pivpn.io"
    domain_name = "raw.githubusercontent.com"
    origin_path = "/pivpn/pivpn/master/auto_install"

    custom_origin_config {
      http_port              = local.custom_origin_http_port
      https_port             = local.custom_origin_https_port
      origin_protocol_policy = local.custom_origin_protocol_policy
      origin_ssl_protocols   = local.custom_origin_ssl_protocols
    }
  }

  default_cache_behavior {
    allowed_methods  = local.allowed_methods
    cached_methods   = local.cached_methods
    target_origin_id = "install.pivpn.io"

    viewer_protocol_policy = local.viewer_protocol_policy
    min_ttl                = local.min_ttl
    default_ttl            = local.default_ttl
    max_ttl                = local.max_ttl

    forwarded_values {
      query_string = local.query_string

      cookies {
        forward = local.forward_cookies
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = local.geo_restriction
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.acm_certificate_arn
    ssl_support_method       = local.ssl_support_method
    minimum_protocol_version = local.minimum_protocol_version
  }
}

resource "aws_cloudfront_distribution" "test" {
  aliases             = ["test.pivpn.io"]
  comment             = "pivpn install script, test branch"
  enabled             = true
  is_ipv6_enabled     = local.is_ipv6_enabled
  default_root_object = local.default_root_object

  origin {
    origin_id   = "test.pivpn.io"
    domain_name = "raw.githubusercontent.com"
    origin_path = "/pivpn/pivpn/test/auto_install"

    custom_origin_config {
      http_port              = local.custom_origin_http_port
      https_port             = local.custom_origin_https_port
      origin_protocol_policy = local.custom_origin_protocol_policy
      origin_ssl_protocols   = local.custom_origin_ssl_protocols
    }
  }

  default_cache_behavior {
    target_origin_id = "test.pivpn.io"
    allowed_methods  = local.allowed_methods
    cached_methods   = local.cached_methods

    viewer_protocol_policy = local.viewer_protocol_policy
    min_ttl                = local.min_ttl
    default_ttl            = local.default_ttl
    max_ttl                = local.max_ttl

    forwarded_values {
      query_string = local.query_string

      cookies {
        forward = local.forward_cookies
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = local.geo_restriction
    }
  }

  viewer_certificate {
    acm_certificate_arn      = local.acm_certificate_arn
    ssl_support_method       = local.ssl_support_method
    minimum_protocol_version = local.minimum_protocol_version
  }
}
