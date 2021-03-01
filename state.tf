terraform {
  backend "s3" {
    bucket         = "terraform-tfstate-pguijarro"
    dynamodb_table = "terraform-tfstate-lock"
    key            = "terraform.tfstate"
    region         = "eu-west-1"
    encrypt        = true
  }
}