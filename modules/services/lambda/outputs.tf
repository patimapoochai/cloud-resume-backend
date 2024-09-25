output "invoke_arn" {
  value       = aws_lambda_function.lambda_function.invoke_arn
  description = "Invoke ARN of the lambda function"
}
