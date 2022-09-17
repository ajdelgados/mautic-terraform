terraform {
  backend "s3" {
    bucket = "tf-aws-us-east-1.om"
    key    = "global/zone/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table  = "tf-aws-us-east-1.om"
  }
}
