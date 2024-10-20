locals {
  github_oidc_url = "token.actions.githubusercontent.com"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "terraform_create" { # cycle here?
  version = "2012-10-17"

  statement {
    sid    = "General"
    effect = "Allow"
    actions = [
      "sts:GetCallerIdentity",
      "route53:ListHostedZones",
      "acm:ListCertificates"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "route53:GetHostedZone"
    ]
    resources = [
      var.hosted_zone_arn
    ]
  }

  statement {
    actions = [
      "acm:DescribeCertificate",
      "acm:GetCertificate"
    ]
    resources = [
      var.patimapoochai_domain_certificate_arn
    ]
  }

  statement {
    actions = [
      "route53:ListTagsForResource"
    ]
    resources = [
      "arn:aws:route53:::healthcheck/*",
      "arn:aws:route53:::hostedzone/*"
    ]
  }

  statement {
    actions = [
      "acm:ListTagsForCertificate"
    ]
    resources = [
      # "arn:aws:acm:us-east-1:879381244858:certificate/*"
      "arn:aws:acm:${var.region}:${data.aws_caller_identity.current.account_id}:certificate/*"
    ]
  }

  statement {
    sid = "CacheTable"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:UpdateTimeToLive",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:ListTagsOfResource"
    ]
    resources = [
      var.cache_table_arn
    ]
  }

  statement {
    sid = "TerraformLockTable"
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource"
    ]
    resources = [
      var.terraform_lock_table_arn
    ]
  }

  statement {
    actions = [
      "apigateway:POST"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/domainnames",
      "arn:aws:apigateway:${var.region}::/restapis"
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
      "s3:CreateBucket",
      "s3:GetBucketPolicy",
      "s3:GetBucketAcl",
      "s3:GetBucketCORS",
      "s3:GetBucketWebsite",
      "s3:GetBucketVersioning",
      "s3:GetAccelerateConfiguration",
      "s3:GetBucketRequestPayment",
      "s3:GetBucketLogging",
      "s3:GetLifecycleConfiguration",
      "s3:GetReplicationConfiguration",
      "s3:GetEncryptionConfiguration",
      "s3:GetBucketObjectLockConfiguration",
      "s3:GetBucketTagging",
      "s3:PutEncryptionConfiguration",
      "s3:PutBucketPublicAccessBlock",
      "s3:PutBucketVersioning",
      "s3:GetBucketPublicAccessBlock"
    ]
    resources = [
      var.terraform_s3_state_arn
      #var.terraform_s3_cloud_resume_pat_state
    ]
  }

  statement {
    actions = [
      "iam:CreateOpenIDConnectProvider"
    ]
    resources = [
      "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/*"
    ]
  }

  statement {
    actions = [
      "iam:CreateRole",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:AttachRolePolicy"
    ]
    resources = [
      # "arn:aws:iam::879381244858:role/github_actions_terraform_role_1"
      aws_iam_role.github_actions_terraform.arn
    ]
  }

  statement {
    actions = [
      "iam:CreateRole",
      "iam:GetRole",
      "iam:ListRolePolicies",
      "iam:ListAttachedRolePolicies",
      "iam:PassRole",
      "iam:AttachRolePolicy"
    ]
    resources = [
      var.lambda_role_arn
    ]
  }

  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]
    resources = [
      aws_iam_policy.github_oidc_safety.arn
      #var.GithubOIDCSafety_policy_arn"aws_iam_policy" "github_oidc_safety"
    ]
  }

  statement {
    actions = [
      "dynamodb:CreateTable",
      "dynamodb:DescribeTable",
      "dynamodb:DescribeContinuousBackups",
      "dynamodb:DescribeTimeToLive",
      "dynamodb:ListTagsOfResource"
    ]
    resources = [
      var.stat_table_arn
    ]
  }

  statement {
    actions = [
      "iam:GetOpenIDConnectProvider"
    ]
    resources = [
      aws_iam_openid_connect_provider.github.arn
      #var.OIDC_provider_tokens_actions_githubusercontent "aws_iam_openid_connect_provider" "github"
    ]
  }

  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]
    resources = [
      aws_iam_policy.github_actions_terraform.arn
    ]
  }

  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/domainnames/*"
    ]
  }

  statement {
    actions = [
      "lambda:CreateFunction",
      "lambda:GetFunction",
      "lambda:ListVersionsByFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:AddPermission",
      "lambda:GetPolicy"
    ]
    resources = [
      var.lambda_function_arn
    ]
  }

  statement {
    actions = [
      "iam:CreatePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion"
    ]
    resources = [
      var.lambda_role_policy_arn
    ]
  }

  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/integrations/*"
    ]
  }

  statement {
    actions = [
      "apigateway:POST"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/deployments"
    ]
  }

  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/deployments/*"
    ]
  }

  statement {
    actions = [
      "apigateway:POST"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/stages"
    ]
  }

  statement {
    actions = [
      "apigateway:GET"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/apis/*/stages/*"
    ]
  }

  statement {
    actions = [
      "apigateway:POST"
    ]
    resources = [
      "arn:aws:apigateway:${var.region}::/usageplans"
    ]
  }

  # statement {
  #   actions = [
  #     "route53:GetChange"
  #   ]
  #   resources = [
  #     "arn:aws:route53:::change/C06843121UC52O6A6QE4V" # WTF is this?
  #   ]
  # }

  statement {
    actions = [
      "route53:ListResourceRecordSets"
    ]
    resources = [
      "arn:aws:route53:::hostedzone/*"
    ]
  }
}

resource "aws_iam_policy" "github_actions_terraform" { # cycle here
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
