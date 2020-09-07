# main.tf

# ---------------------------------------------------------------------------------------------------------------------
# CREATE AN S3 BUCKET TO SAVE TERRAFORM-STATE 
# ---------------------------------------------------------------------------------------------------------------------

#terraform {
#  required_version = ">=0.12"
#  required_providers {
#    aws = {
 #     version = "~> 2.7"
 #   }
 # }
#}

# ------------------------------------------------------------------------------
# CONFIGURE AWS CONNECTION
# ------------------------------------------------------------------------------

provider "aws" {
  region = "us-west-1"

}

# ------------------------------------------------------------------------------
# CREATE THE S3 BUCKET
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "gogreen-3tier-tf-state" {
  bucket        = "gogreen-3tier-tf-state-2"
  force_destroy = true

  # Enable versioning so we can see the full revision history of our
  # state files
  versioning {
    enabled = true
  }

  # Enable server-side encryption by default
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}



