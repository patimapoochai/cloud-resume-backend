variable "namespace" {
  description = "Namespace string added at the end of resources"
  type        = string
}

variable "terraform_s3_backend_bucket" {
  type = string
}
