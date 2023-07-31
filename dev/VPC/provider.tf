terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  access_key = "${var.ACCESS_KEY_ID}"
  secret_key = "${var.SECRET_KEY}"
}