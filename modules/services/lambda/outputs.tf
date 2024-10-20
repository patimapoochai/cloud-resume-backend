output "invoke_arn" {
  value       = aws_lambda_function.lambda_function.invoke_arn
  description = "Invoke ARN of the lambda function"
}

output "lambda_role_arn" {
  value = aws_iam_role.lambda_role.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.lambda_function.arn
}

output "lambda_role_policy_arn" {
  value = aws_iam_policy.lambd_role_policy.arn
}

