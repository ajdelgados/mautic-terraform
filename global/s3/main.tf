terraform {
  backend "s3" {
    bucket = "tf-aws-us-east-1.om"
    key    = "global/s3/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "tf-aws-us-east-1.om"

  versioning {
    enabled =  true
  }

  lifecycle {
    prevent_destroy= true
  }
}
