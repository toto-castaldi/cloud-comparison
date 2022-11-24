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
    filter_suffix       = ".txt"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}
