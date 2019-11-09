variable "aws_profile" {}
variable "aws_region" {}

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "${var.aws_region}"
}

// Role for Lambda
resource "aws_iam_role" "lambda-role-for-lex" {
  name               = "lambda-lex-trigger"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

// policy to output log for Lambda
resource "aws_iam_role_policy" "lambda-log-output" {
  role   = "${aws_iam_role.lambda-role-for-lex.id}"
  name   = "lambda-log-output"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

// Access from Lex
resource "aws_iam_role_policy" "lex-bot" {
  role   = "${aws_iam_role.lambda-role-for-lex.id}"
  name   = "policy-for-lex-bot"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "lex:PostContent",
        "lex:PostText"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "./var/workspace/lambda_function"
  output_path = "./var/lambda.zip"
}

resource "aws_lambda_function" "gc_lex_lambda" {
  function_name    = "answerBySelectedNum"
  filename         = "./var/lambda.zip"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "nodejs10.x"
  timeout          = 150
  role             = "${aws_iam_role.lambda-role-for-lex.arn}"
  #role            = "arniam::${var.account_id}:role/XXXXXXRole"
  #role             = "${aws_iam_role.iam_for_lambda.arn}"
}
