# TODO
# - more granular cloudwatch permissions

data "aws_caller_identity" "current_account" {
}

data "aws_iam_policy_document" "lambda_policy_doc" {
  version = "2012-10-17"
  statement {
    sid    = "AllowDynamoDBAccess"
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:PutItem",
      "dynamodb:Query"
    ]
    resources = [
      var.stat_table_arn,
      var.cache_table_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogsEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:*"
    ]
  }
}

resource "aws_iam_policy" "lambd_role_policy" {
  name   = "cloud-resume-lambda-role-policy_${var.namespace}"
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "lambda.amazonaws.com"
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "cloud-resume-lambda-role_${var.namespace}"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

}

data "aws_iam_policy" "LambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_role_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambd_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "basic_execution_attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.LambdaBasicExecutionRole.arn
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "cloud-resume-lambda-function_${var.namespace}"
  role          = aws_iam_role.lambda_role.arn

  handler  = "lambda_function.lambda_handler"
  runtime  = "python3.12"
  filename = var.code_filename

  timeout = 7

  tags = {
    TestTag = "Active"
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current_account.account_id}:${var.api_id}/*/${var.api_http_method}${var.api_resource_path}"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name = "/aws/lambda/cloud-resume-lambda-function_${var.namespace}"
}
