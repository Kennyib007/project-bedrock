# IAM Role for Read-Only Developer Access
resource "aws_iam_user" "developer_readonly" {
  name = "${var.project_name}-developer-readonly"
  path = "/"

  tags = {
    Project = var.project_name
  }
}

resource "aws_iam_access_key" "developer_readonly" {
  user = aws_iam_user.developer_readonly.name
}

data "aws_iam_policy_document" "developer_readonly" {
  statement {
    effect = "Allow"
    actions = [
      "eks:Describe*",
      "eks:List*",
      "logs:Get*",
      "logs:Describe*",
      "logs:List*",
      "ec2:Describe*",
      "dynamodb:Describe*",
      "dynamodb:List*",
      "rds:Describe*",
      "rds:List*",
      "s3:Get*",
      "s3:List*",
      "iam:Get*",
      "iam:List*"
    
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "developer_readonly" {
  name        = "${var.project_name}-developer-readonly-policy"
  path        = "/"
  description = "Read-only access policy for developers"
  policy      = data.aws_iam_policy_document.developer_readonly.json
}

resource "aws_iam_user_policy_attachment" "developer_readonly" {
  user       = aws_iam_user.developer_readonly.name
  policy_arn = aws_iam_policy.developer_readonly.arn
}


######
# IRSA role for Carts
resource "aws_iam_role" "carts_irsa" {
  name = "project-bedrock-carts-irsa"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks.url, "https://", "")}:sub" = "system:serviceaccount:default:carts"
          }
        }
      }
    ]
  })
}

# Policy for Carts -> DynamoDB
resource "aws_iam_role_policy" "carts_dynamodb_policy" {
  name = "carts-dynamodb-access"
  role = aws_iam_role.carts_irsa.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:Query",
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:DescribeTable"
        ],
        Resource = [
          "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/project-bedrock-carts",
          "arn:aws:dynamodb:us-east-1:${data.aws_caller_identity.current.account_id}:table/project-bedrock-carts/index/*"
        ]
      }
    ]
  })
}
