provider "aws" {
  region = "us-east-2"
}

terraform {
  backend "s3" {
    bucket = "tf-aws-us-east-1.om"
    key    = "ec2_multi/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "mautic-instance" {
  for_each = toset(["prueba1", "prueba2"])
  source = "../modules"
  name = "${each.key}-instance"
  ami = data.aws_ami.ubuntu.id
}