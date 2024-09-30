locals {
  github_oidc_url = "token.actions.githubusercontent.com"
}

data "aws_iam_policy_document" "terraform_create" {
  version = "2012-10-17"

  statement {
    sid    = "ACM"
    effect = "Allow"
    actions = [
      "acm:ListCertificates",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "DynamoDBTableLevel"
    effect = "Allow"
    actions = [
      "dynamodb:CreateTable",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "DynamoDBRecordLevel"
    effect = "Allow"
    actions = [
      "dynamodb:UpdateTimeToLive"
    ]
    resources = [
      "*", # change this to specific table?
    ]
  }

  statement {
    sid    = "IAMCreate"
    effect = "Allow"
    actions = [
      "iam:CreateRole",
      "iam:CreateServiceLinkedRole",
      "iam:CreatePolicy"
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "APIGateway"
    actions = [
      "apigateway:GET",
      "apigateway:PUT",
      "apigateway:PATCH",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "Lambda"
    actions = [
      "lambda:CreateFunction",
      "lambda:AddPermission",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "Route53"
    actions = [
      "route53:ChangeResourceRecordSets",
      "route53:ListHostedZones",
    ]
    resources = [
      "*", # change this to only the specific hosted zone?
    ]
  }

  statement {
    sid = "S3BucketLevel"
    actions = [
      "s3:CreateBucket",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid = "S3ObjectLevel"
    actions = [
      "s3:PutBucketVersioning",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutEncryptionConfiguration",
    ]
    resources = [
      "*", # change this to specific bucket
    ]
  }
}

resource "aws_iam_policy" "github_actions_terraform" {
  name        = "GithubActionsTerraformPermissions_${var.namespace}"
  description = "Permissions for the Github actions service account for cloud resume challenge"

  policy = data.aws_iam_policy_document.terraform_create.json
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://${local.github_oidc_url}"
  client_id_list = [
    "sts.amazonaws.com"
  ]
  thumbprint_list = [
    "d89e3bd43d5d909b47a18977aa9d5ce36cee184c"
  ]
}

data "aws_iam_policy_document" "oidc_safety" {
  version = "2012-10-17"
  statement {
    sid    = "OidcSafeties"
    effect = "Deny"
    actions = [
      "sts:AssumeRole",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "github_oidc_safety" {
  name        = "GithubOIDCSafety_${var.namespace}"
  description = "Deny service accounts from assuming another role in cloud resume challenge"

  policy = data.aws_iam_policy_document.oidc_safety.json
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "github_actions_oidc_access" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.github_oidc_url}"
      ]
    }
    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:patimapoochai/cloud-resume-backend:ref:refs/heads/main"]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

output "principals" {
  value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}::${local.github_oidc_url}"
}

resource "aws_iam_role" "github_actions_terraform" {
  name               = "github_actions_terraform_role_${var.namespace}"
  assume_role_policy = data.aws_iam_policy_document.github_actions_oidc_access.json
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_oidc" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_oidc_safety.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform_deployment" {
  role       = aws_iam_role.github_actions_terraform.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}
