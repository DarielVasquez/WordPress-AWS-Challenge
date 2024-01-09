provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    region = "us-east-1"
  }
}

module "ec2" {
  source          = "./modules/ec2"
  name_prefix     = var.name_prefix
  devops_tag      = var.devops_tag
  project_tag     = var.project_tag
  env_tag         = var.env_tag
  ami_id          = var.ami_id
  instance_type   = var.instance_type
  key_pair        = var.key_pair
}
