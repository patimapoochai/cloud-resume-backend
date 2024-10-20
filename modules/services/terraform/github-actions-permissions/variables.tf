variable "namespace" {
  description = "Namespace string added at the end of resources"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "terraform_s3_backend_bucket" {
  type = string
}

variable "hosted_zone_arn" {
  description = "ARN of the hosted zone for the domain name"
  type        = string
}

variable "patimapoochai_domain_certificate_arn" {
  description = "ARN of the certificate for using TLS with the domain"
  type        = string

}

variable "cache_table_arn" {
  type = string
}

variable "terraform_lock_table_arn" {
  type = string
}

variable "terraform_s3_state_arn" {
  type = string
}

variable "lambda_role_arn" {
  type = string
}

variable "stat_table_arn" {
  type = string
}

variable "lambda_function_arn" {
  type = string
}

variable "lambda_role_policy_arn" {
  type = string
}
