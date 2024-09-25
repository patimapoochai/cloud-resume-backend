output "api_id" {
  value = aws_api_gateway_rest_api.visitor-api.id
}

output "api_method" {
  value       = aws_api_gateway_method.visitor-post.http_method
  description = "POST method"
}

output "api_resource_path" {
  value = aws_api_gateway_resource.visitor.path
}

output "api_custom_domain_name" {
  value       = aws_api_gateway_domain_name.resumeapi.regional_domain_name
  description = "API FQDN from custom domain name"
}

output "api_custom_domain_zone_id" {
  value = aws_api_gateway_domain_name.resumeapi.regional_zone_id
}
