# call github-actions module
module "github_actions_permissions" {
  source                      = "./github-actions-permissions"
  namespace                   = var.namespace
  terraform_s3_backend_bucket = ""
}

# call terraform-remote-state module
module "terraform-s3-remote-state" {
  source                   = "./terraform-remote-state"
  s3_state_bucket_name     = var.s3_state_bucket_name
  dynamodb_lock_table_name = var.dynamodb_lock_table_name
}
