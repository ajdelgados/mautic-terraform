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
  #data.aws_ami.ubuntu.id
  for_each = {
    orquestaagency = {
      ami = "ami-0b29b6e62f2343b46"
    },
    popayan = {
      ami = "ami-0b29b6e62f2343b46"
    },
    implanet = {
      ami = "ami-0117d177e96a8481c"
    },
    mydesk = {
      ami = "ami-0117d177e96a8481c"
    },
    votella = {
      ami = "ami-039af3bfc52681cd5"
    },
    wowpets = {
      ami = data.aws_ami.ubuntu.id
    },
  }
  source = "../modules"
  name = "${each.key}-instance"
  ami = each.value.ami
}