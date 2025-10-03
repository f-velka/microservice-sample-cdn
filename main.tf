terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.60"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

provider "aws" {
  alias  = "cloudfront"
  region = "us-east-1"
}

data "aws_cloudfront_cache_policy" "disabled" {
  name     = "Managed-CachingDisabled"
  provider = aws.cloudfront
}

data "aws_cloudfront_origin_request_policy" "all_viewer_except_host" {
  name     = "Managed-AllViewerExceptHostHeader"
  provider = aws.cloudfront
}

locals {
  lambda_origin_without_scheme = replace(replace(var.lambda_function_url, "https://", ""), "http://", "")
  lambda_origin_domain         = element(split("/", local.lambda_origin_without_scheme), 0)
}

resource "aws_cloudfront_origin_access_control" "lambda" {
  provider = aws.cloudfront

  name                            = "lambda-function-url-oac"
  description                     = "Origin access control for Lambda Function URL"
  origin_access_control_origin_type = "lambda"
  signing_behavior                = "always"
  signing_protocol                = "sigv4"
}

resource "aws_cloudfront_distribution" "this" {
  provider = aws.cloudfront

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Lambda Function URL origin"
  price_class         = "PriceClass_All"
  wait_for_deployment = true

  origin {
    domain_name              = local.lambda_origin_domain
    origin_id                = "lambda-function-url"
    origin_access_control_id = aws_cloudfront_origin_access_control.lambda.id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols     = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id         = "lambda-function-url"
    viewer_protocol_policy   = "redirect-to-https"
    allowed_methods          = ["GET", "HEAD", "OPTIONS", "PUT", "PATCH", "POST", "DELETE"]
    cached_methods           = ["GET", "HEAD"]
    cache_policy_id          = data.aws_cloudfront_cache_policy.disabled.id
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.all_viewer_except_host.id
    compress                 = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_lambda_permission" "cloudfront_invoke" {
  statement_id           = "AllowExecutionFromCloudFront"
  action                 = "lambda:InvokeFunctionUrl"
  function_name          = var.lambda_function_arn
  principal              = "cloudfront.amazonaws.com"
  source_arn             = aws_cloudfront_distribution.this.arn
  function_url_auth_type = "AWS_IAM"
}
