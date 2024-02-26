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

# module "ec2" {
#   source           = "./modules/ec2"
#   name_prefix      = var.name_prefix
#   devops_tag       = var.devops_tag
#   project_tag      = var.project_tag
#   env_tag          = var.env_tag
#   ami_id           = var.ami_id
#   instance_type    = var.instance_type
#   key_pair         = var.key_pair
#   hosted_zone_name = var.hosted_zone_name
#   subnet_id        = module.vpc.public_subnet
#   security_group   = module.vpc.security_group
#   ecr_repository_url = module.ecr.ecr_repository_url
#   ecr_repository_name = module.ecr.ecr_repository_name
#   docker_image_tag = var.docker_image_tag
#   aws_region = var.aws_region
# }

module "asg" {
  source           = "./modules/asg"
  name_prefix      = var.name_prefix
  devops_tag       = var.devops_tag
  project_tag      = var.project_tag
  env_tag          = var.env_tag
  ami_id           = var.ami_id
  instance_type    = var.instance_type
  key_pair         = var.key_pair
  security_group   = module.vpc.security_group
  public_subnet = module.vpc.public_subnet
  public_subnet_2 = module.vpc.public_subnet_2
  ecr_repository_url = module.ecr.ecr_repository_url
  ecr_repository_name = module.ecr.ecr_repository_name
  docker_image_tag = var.docker_image_tag
  aws_region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  name_prefix     = var.name_prefix
  devops_tag      = var.devops_tag
  project_tag     = var.project_tag
  env_tag         = var.env_tag
}

module "route53" {
  source = "./modules/route53"
  name_prefix     = var.name_prefix
  devops_tag      = var.devops_tag
  project_tag     = var.project_tag
  env_tag         = var.env_tag
  hosted_zone_name = var.hosted_zone_name
  zone_id = var.zone_id
  resource_domain_name = module.alb.alb_dns_name
  resource_hosted_zone = module.alb.alb_zone_id
}

module "alb" {
  source = "./modules/alb"
  name_prefix     = var.name_prefix
  devops_tag      = var.devops_tag
  project_tag     = var.project_tag
  env_tag         = var.env_tag
  vpc = module.vpc.vpc
  public_subnet = module.vpc.public_subnet
  public_subnet_2 = module.vpc.public_subnet_2
  security_group = module.vpc.security_group
  certificate_arn = var.certificate_arn
  # asg_name = module.asg.asg_name
}

module "ecr" {
  source = "./modules/ecr"
  name_prefix     = var.name_prefix
  devops_tag      = var.devops_tag
  project_tag     = var.project_tag
  env_tag         = var.env_tag
}

module "ecs" {
  source = "./modules/ecs"
  ecs_image = "${module.ecr.ecr_repository_url}:${var.docker_image_tag}"
  name_prefix     = var.name_prefix
  devops_tag      = var.devops_tag
  project_tag     = var.project_tag
  env_tag         = var.env_tag
  public_subnet = module.vpc.public_subnet
  public_subnet_2 = module.vpc.public_subnet_2
  security_group = module.vpc.security_group
  target_group = module.alb.target_group
  alb_listener = module.alb.alb_listener
  asg_arn = module.asg.asg_arn
  asg = module.asg
  vpc = module.vpc.vpc
  mysql_database = var.mysql_database
  mysql_user = var.mysql_user
  # cloudwatch_log = module.cloudwatch.cloudwatch_log
  # secretmanager_arn = var.secretmanager_arn
}
