terraform {
  backend "s3" {
    bucket = "tf-aws-us-east-1.om"
    key    = "ec2_multi/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table  = "tf-aws-us-east-1.om"
  }
}

provider "aws" {
  region = "us-east-2"
}
