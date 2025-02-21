provider "aws" {
   region      = var.aws_region
  #  profile     = "default"
  #  access_key  = ""
  #  secret_key  = ""
}

terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
      version = "2.7.0"
    }
  }
}

provider "archive" {
  # Configuration options
}