variable "aws_region" {
  default = "us-west-2"
}

provider "aws" {
  region = "${var.aws_region}"
}

resource "aws_lambda_function" "gc_support_chat_lex_bot" {
  filename         = "./var/lambda.zip"
  function_name    = "answerBySelectedNum"
  role             = "${aws_iam_role.iam_for_lambda_tf.arn}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_zip.output_base64sha256}"
  runtime          = "nodejs10.x"
  timeout          = 150
  #role            = "arniam::${var.account_id}:role/XXXXXXRole"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "./var/workspace/lambda_function"
  output_path = "./var/lambda.zip"
}

resource "aws_iam_role" "iam_for_lambda_tf" {
  name = "iam_for_lambda_tf"

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
