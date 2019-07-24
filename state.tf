terraform {
  required_version = "~> 0.12.0"

  backend "s3" {
    //    dynamodb_table = "not used see https://www.terraform.io/docs/backends/types/s3.html if you want to enable"
    bucket  = "foxpass-vpn-project-state"
    encrypt = true
    region  = "eu-west-2"
    key     = "terrafrom/state/v2/global"
  }
}

resource "aws_kms_key" "state-key" {
  description             = "This key is used to encrypt state bucket objects"
  deletion_window_in_days = 10

  tags = module.vpn_label.tags
}

resource "aws_s3_bucket" "terraform-state-storage-s3" {
  bucket = "foxpass-vpn-project-state"
  region = "eu-west-2"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = module.vpn_label.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.state-key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "private" {
  bucket = aws_s3_bucket.terraform-state-storage-s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}