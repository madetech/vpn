terraform {
  backend "s3" {
    //    dynamodb_table = "not used in this project due to low useage"
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