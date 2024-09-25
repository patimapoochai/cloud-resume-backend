variable "stat_table_arn" {
  description = "The ARN of the stat table"
  type        = string
}

variable "cache_table_arn" {
  description = "The ARN of the cache table"
  type        = string
}

variable "code_filename" {
  description = "Path to the lambda code zip file"
  type        = string
}

variable "namespace" {
  description = "Name space added at the end of resource names"
  type        = string
}

variable "region" {
  description = "From terraform provider docs"
  type        = string
}


variable "api_http_method" {
  description = "API method for use with integration"
  type        = string
}

variable "api_resource_path" {
  description = "Path of the API resource for integration"
  type        = string
}

variable "api_id" {
  description = "API id for integration"
  type        = string
}
