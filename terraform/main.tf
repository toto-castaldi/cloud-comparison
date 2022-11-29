terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40.0"
    }
  }

  required_version = ">= 1.3.5"
}

provider "aws" {
  region  = "eu-central-1"
}

data "archive_file" "lambda_zip_file" {
  type        = "zip"
  output_path = "/tmp/lambda_zip_file.zip"
  source {
    content  = file("../src/lambda.py")
    filename = "lambda.py"
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow"
      }
    ]
}
EOF
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name   = "lambda_logging_policy"
  policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:logs:*:*:*"
      }
    ]
}
EOF
}

resource "aws_iam_policy" "lambda_s3_policy" {
  name   = "lambda_s3_policy"
  policy = <<EOF
{
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : [
          "s3:GetObject",
          "s3:PutObject"
        ],
        "Effect" : "Allow",
        "Resource" : "arn:aws:s3::*:*"
      }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.id
  policy_arn = aws_iam_policy.lambda_s3_policy.arn
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.serverless_logic.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_lambda_function" "serverless_logic" {
  function_name     = "serverless_logic"
  description       = "Serverless Logic"
  handler           = "lambda.lambda_handler"
  runtime           = "python3.8"
  filename          = "${data.archive_file.lambda_zip_file.output_path}"
  source_code_hash  = "${data.archive_file.lambda_zip_file.output_base64sha256}"
  role              = aws_iam_role.iam_for_lambda.arn
  layers            = ["arn:aws:lambda:eu-central-1:770693421928:layer:Klayers-p38-Pillow:5"]
}

resource "aws_s3_bucket" "bucket" {
  bucket = "toto-castaldi-00"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.serverless_logic.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
    filter_suffix       = ".png"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.serverless_logic.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}
