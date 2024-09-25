variable "namespace" {
  description = "Name space added at the end of resource names"
  type        = string
}

variable "lambda-invoke-arn" {
  description = "ARN used for invoking lambda from API gateway"
  type        = string
}

variable "hosted_zone_name" {
  type = string
}
