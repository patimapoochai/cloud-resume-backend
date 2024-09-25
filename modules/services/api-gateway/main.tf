resource "aws_api_gateway_rest_api" "visitor-api" {
  name = "visitor-api_${var.namespace}"
}

resource "aws_api_gateway_resource" "visitor" {
  rest_api_id = aws_api_gateway_rest_api.visitor-api.id
  parent_id   = aws_api_gateway_rest_api.visitor-api.root_resource_id
  path_part   = "visitor"
}

resource "aws_api_gateway_method" "visitor-post" {
  resource_id   = aws_api_gateway_resource.visitor.id
  rest_api_id   = aws_api_gateway_rest_api.visitor-api.id
  authorization = "NONE"
  http_method   = "POST"
}

resource "aws_api_gateway_integration" "visitor-get-integration" {
  rest_api_id = aws_api_gateway_rest_api.visitor-api.id
  resource_id = aws_api_gateway_resource.visitor.id
  http_method = aws_api_gateway_method.visitor-post.http_method

  type                    = "AWS_PROXY"
  uri                     = var.lambda-invoke-arn
  integration_http_method = "POST"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.visitor-api.id

  depends_on = [
    aws_api_gateway_method.visitor-post,
    aws_api_gateway_integration.visitor-get-integration
  ]
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.visitor-api.id
  stage_name    = "prod"
}

resource "aws_api_gateway_usage_plan" "five-hundered" {
  name = "cloud-resume-five-hundred_${var.hosted_zone_name}"

  api_stages {
    api_id = aws_api_gateway_rest_api.visitor-api.id
    stage  = aws_api_gateway_stage.prod.stage_name
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

data "aws_acm_certificate" "patimapoochai" {
  domain   = var.hosted_zone_name
  statuses = ["ISSUED"]
}

resource "aws_api_gateway_domain_name" "resumeapi" {
  regional_certificate_arn = data.aws_acm_certificate.patimapoochai.arn
  domain_name              = "resumeapi.${var.hosted_zone_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_base_path_mapping" "resumeapi-visitor" {
  api_id      = aws_api_gateway_rest_api.visitor-api.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  domain_name = aws_api_gateway_domain_name.resumeapi.domain_name
}

