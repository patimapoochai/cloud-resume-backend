terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.67"
    }
  }
  # s3 backend bootstrap instructions
  # 1. comment backend "s3" block
  # 2. apply fresh terraform configuration
  # 3. uncomment backend "s3" block
  # 4. (development) export AWS_PROFILE=***
  # 5. run terraform init
  # s3 backend unboostrap is reverse of above instructions
  backend "s3" {
    bucket         = "cloud-resume-pat-state"
    key            = "global/s3/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "cloud-resume-terraform-lock"
    encrypt        = true
  }

  required_version = ">= 1.9.4"
}

provider "aws" {
  region  = "us-east-1"
  profile = var.aws_profile
  default_tags {
    tags = {
      Project = "Cloud-Resume-Backend"
    }
  }
}

module "github_actions_terraform" {
  source    = "./modules/services/terraform"
  namespace = "1"

  s3_state_bucket_name     = "cloud-resume-pat-state"
  dynamodb_lock_table_name = "cloud-resume-terraform-lock"

  cache_table_arn = module.dynamodb-tables.cache_table_arn
  stat_table_arn  = module.dynamodb-tables.stat_table_arn

  lambda_role_arn        = module.lambda-function.lambda_role_arn
  lambda_function_arn    = module.lambda-function.lambda_function_arn
  lambda_role_policy_arn = module.lambda-function.lambda_role_policy_arn
}

module "route53" {
  source = "./modules/services/dns"

  api_domain_name = module.api-gateway.api_custom_domain_name
  api_zone_id     = module.api-gateway.api_custom_domain_zone_id
}

module "dynamodb-tables" {
  source = "./modules/services/dynamodb"
}

module "lambda-function" {
  source = "./modules/services/lambda"

  cache_table_arn = module.dynamodb-tables.cache_table_arn
  stat_table_arn  = module.dynamodb-tables.stat_table_arn

  code_filename = "${path.module}/out/code.zip"
  namespace     = "1"
  region        = "us-east-1"

  api_id            = module.api-gateway.api_id
  api_resource_path = module.api-gateway.api_resource_path
  api_http_method   = module.api-gateway.api_method
}

module "api-gateway" {
  source            = "./modules/services/api-gateway"
  namespace         = "1"
  lambda-invoke-arn = module.lambda-function.invoke_arn

  hosted_zone_name = "patimapoochai.net"
}

