terraform {
  required_version = "~>0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>3.29.0"
    }
  }
}

provider "aws" {
  region = "eu-west-1"
  shared_credentials_file = "~/.aws/credentials"
}

resource "aws_s3_bucket" "tfstate" {
  bucket = "terraform-tfstate-pguijarro"
  acl    = "private"
  
  force_destroy = true

  versioning {
    enabled = true
  }

  # lifecycle {
  #  prevent_destroy = true
  # }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Terraform = "true"
  }
}

resource "aws_s3_bucket_public_access_block" "default" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "tfstate_lock" {
  name = "terraform-tfstate-lock"
  read_capacity  = 1
  write_capacity = 1
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Terraform = "true"
  }
}

data "aws_secretsmanager_secret" "apikey" {
  name = "prod"
}

data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.apikey.id
}

output "secret_pass" {
  value = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["TEST_KEY"]
  sensitive = true
}

