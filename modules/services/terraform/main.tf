data "aws_route53_zone" "patimapoochai_domain" {
  name = "patimapoochai_domain.net." # this should be variable
}

data "aws_acm_certificate" "patimapoochai_domain" {
  domain   = "patimapoochai_domain.net." # this should also be variable
  statuses = ["ISSUED"]
}

# call github-actions module
module "github_actions_permissions" {
  source                      = "./github-actions-permissions"
  namespace                   = var.namespace
  terraform_s3_backend_bucket = ""
  region                      = "us-east-1"

  hosted_zone_arn                      = data.aws_route53_zone.patimapoochai_domain.arn
  patimapoochai_domain_certificate_arn = data.aws_acm_certificate.patimapoochai_domain.arn

  cache_table_arn = var.cache_table_arn
  stat_table_arn  = var.stat_table_arn

  lambda_role_arn        = var.lambda_role_arn
  lambda_function_arn    = var.lambda_function_arn
  lambda_role_policy_arn = var.lambda_role_policy_arn

  terraform_s3_state_arn   = module.terraform-s3-remote-state.state_bucket_arn
  terraform_lock_table_arn = module.terraform-s3-remote-state.state_bucket_arn
}

# call terraform-remote-state module
module "terraform-s3-remote-state" {
  source                   = "./terraform-remote-state"
  s3_state_bucket_name     = var.s3_state_bucket_name
  dynamodb_lock_table_name = var.dynamodb_lock_table_name
}
