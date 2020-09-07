
# main.tf

terraform {

  required_version = " < 4.0"
  backend "s3" {
    encrypt = true
    bucket  = "gogreen-3tier-tf-state-2"
    region  = "us-west-1"
    key     = "terraform/state/gogreencdn.tfstate"
  }
}


locals {
  bucket_name             = "origin-s3-bucket-gogreen.id"
  destination_bucket_name = "replica-s3-bucket-gogreen"
  origin_region           = "us-west-1"
  replica_region          = "us-west-1"
}

provider "aws" {
  region = local.origin_region

}

provider "aws" {
  region = local.replica_region

  alias = "replica"
}

data "aws_caller_identity" "current" {}



resource "aws_kms_key" "replica" {
  provider = aws.replica

  description             = "S3 bucket replication KMS key"
  deletion_window_in_days = 7
}

module "log_bucket" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket"

  bucket                         = "logs-gogreen"
  acl                            = "log-delivery-write"
  force_destroy                  = true
  attach_elb_log_delivery_policy = true
}
module "replica_bucket" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket"

  providers = {
    aws = aws.replica
  }

  bucket = local.destination_bucket_name
  acl    = "private"

  versioning = {
    enabled = true
  }
}

module "s3_bucket" {
  source = "git@github.com:terraform-aws-modules/terraform-aws-s3-bucket"

  bucket = local.bucket_name
  acl    = "private"
 

  versioning = {
    enabled = true
  }

  replication_configuration = {
    role = aws_iam_role.replication.arn

    rules = [
      {
        id       = "foo"
        status   = "Enabled"
        priority = 10

        source_selection_criteria = {
          sse_kms_encrypted_objects = {
            enabled = true
          }
        }

        filter = {
          prefix = "one"
          tags = {
            ReplicateMe = "Yes"
          }
        }

        destination = {
          bucket             = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class      = "STANDARD"
          replica_kms_key_id = aws_kms_key.replica.arn
          account_id         = data.aws_caller_identity.current.account_id
          access_control_translation = {
            owner = "Destination"
          }
        }
      },
      {
        id       = "bar"
        status   = "Enabled"
        priority = 20

        destination = {
          bucket        = "arn:aws:s3:::${local.destination_bucket_name}"
          storage_class = "STANDARD"
        }


        filter = {
          prefix = "two"
          tags = {
            ReplicateMe = "Yes"
          }
        }

      },

    ]
  }
  website = {
    index_document = "index.html"
    error_document = "error.html"
    routing_rules = jsonencode([{
      Condition : {
        KeyPrefixEquals : "docs/"
      },
      Redirect : {
        ReplaceKeyPrefixWith : "documents/"
      }
    }])

  }

  logging = {
    target_bucket = module.log_bucket.this_s3_bucket_id
    target_prefix = "log/"
  }

  cors_rule = [
    {
      allowed_methods = ["PUT", "POST"]
      allowed_origins = ["https://modules.tf", "https://terraform-aws-modules.modules.tf"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
      }, {
      allowed_methods = ["PUT"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  lifecycle_rule = [
    {
      id      = "log"
      enabled = true
      prefix  = "log/"

      tags = {
        rule      = "log"
        autoclean = "true"
      }

      transition = [
        {
          days          = 30
          storage_class = "ONEZONE_IA"
          }, {
          days          = 60
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 90
      }

      noncurrent_version_expiration = {
        days = 30
      }
    },
    {
      id                                     = "log1"
      enabled                                = true
      prefix                                 = "log1/"
      abort_incomplete_multipart_upload_days = 7

      noncurrent_version_transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "ONEZONE_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
      ]

      noncurrent_version_expiration = {
        days = 300
      }
    },
  ]


  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        kms_master_key_id = aws_kms_key.replica.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }


  // S3 bucket-level Public Access Block configuration
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}


# --------------------------------------------------------------------------
# Creating Origin Access Identity for CloudFront 
# --------------------------------------------------------------------------

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Some comment"
}
resource "aws_cloudfront_distribution" "s3_distribution_task" {
  origin {
    domain_name = module.s3_bucket.this_s3_bucket_bucket_regional_domain_name
    origin_id   = module.s3_bucket.this_s3_bucket_id
    s3_origin_config {

      # origin_access_identity = "origin-access-identity/cloudfront/ABCDEFG1234567"
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }
  enabled         = true
  is_ipv6_enabled = true
  comment         = "GoGreen web ditribution"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = module.s3_bucket.this_s3_bucket_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = module.s3_bucket.this_s3_bucket_id
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 3156000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_200"
  restrictions {
    geo_restriction {
      restriction_type = "blacklist"
      locations        = ["CA"]
    }
  }
  tags = {
    Environment = "test"
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  retain_on_delete = true
}

# ---------------------------------------------------------------------------------
# Create AWS Bucket Policy for CloudFront
# ---------------------------------------------------------------------------------
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_bucket.this_s3_bucket_arn}/*"]
    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn}"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3BucketPolicy" {
  bucket = module.s3_bucket.this_s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}
