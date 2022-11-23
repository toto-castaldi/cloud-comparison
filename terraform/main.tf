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

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "toto-castaldi-00"

}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "serverless-logic"
  description   = "Serverless Logic"
  handler       = "lambda.lambda_handler"
  runtime       = "python3.8"

  source_path = "../src"
  
}
