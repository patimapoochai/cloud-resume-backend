variable "namespace" {
  description = "Namespace string added at the end of resources"
  type        = string
}

variable "s3_state_bucket_name" {
  description = "s3 bucket name for remote terraform state"
  type        = string
}

variable "dynamodb_lock_table_name" {
  description = "dynamodb table to store state file lock"
  type        = string
}
