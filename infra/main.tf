terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.81.0"
    }
  }
}
provider "aws" {}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  region       = data.aws_region.current.name
  account_id   = data.aws_caller_identity.current.account_id
  s3_origin_id = "DeploymentS3"
}

resource "aws_s3_bucket" "deployment" {
  force_destroy = true
  bucket        = "deployment-${local.region}-${local.account_id}"
}

resource "aws_s3_bucket_public_access_block" "block" {
  bucket                  = aws_s3_bucket.deployment.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.deployment.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_cloudfront_origin_access_control" "origin_access_control" {
  name                              = "s3AccessControl"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_response_headers_policy" "policy" {
  name = "cors-policy"

  cors_config {
    access_control_allow_credentials = false
    origin_override                  = false

    access_control_allow_methods {
      items = ["GET"]
    }

    access_control_allow_origins {
      items = ["*"]
    }

    access_control_allow_headers {
      items = ["*"]
    }
  }
}

resource "aws_cloudfront_distribution" "distribution" {
  depends_on          = [aws_s3_bucket_public_access_block.block, aws_s3_bucket_ownership_controls.ownership]
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name              = aws_s3_bucket.deployment.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.origin_access_control.id
  }

  default_cache_behavior {
    response_headers_policy_id = aws_cloudfront_response_headers_policy.policy.id
    allowed_methods            = ["HEAD", "GET", "OPTIONS"]
    cached_methods             = ["HEAD", "GET", "OPTIONS"]
    target_origin_id           = local.s3_origin_id
    viewer_protocol_policy     = "redirect-to-https"
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  tags = {
    Name = "mfs-cdn"
  }
}

resource "aws_ssm_parameter" "distribution_id" {
  name  = "mfs-cdn-id"
  type  = "String"
  value = aws_cloudfront_distribution.distribution.id
}

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"
    principals {
      identifiers = ["cloudfront.amazonaws.com"]
      type        = "Service"
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.deployment.arn}/*"]
    condition {
      test     = "StringEquals"
      values   = [aws_cloudfront_distribution.distribution.arn]
      variable = "AWS:SourceArn"
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.deployment.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}