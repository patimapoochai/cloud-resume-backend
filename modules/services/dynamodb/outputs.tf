output "stat_table_arn" {
  value       = aws_dynamodb_table.stat_table.arn
  description = "ARN of the stat table"
}

output "cache_table_arn" {
  value       = aws_dynamodb_table.cache_table.arn
  description = "ARN of the cahce table"
}
