resource "aws_dynamodb_table" "stat_table" {
  name     = "cloud-resume-stat_1"
  hash_key = "Stat"

  attribute {
    name = "Stat"
    type = "S"
  }

  write_capacity = 1
  read_capacity  = 1
}

resource "aws_dynamodb_table" "cache_table" {
  name     = "cloud-resume-cache_1"
  hash_key = "UserID"

  attribute {
    name = "UserID"
    type = "S"
  }

  ttl {
    attribute_name = "TTL"
    enabled        = true
  }

  write_capacity = 1
  read_capacity  = 1
}
