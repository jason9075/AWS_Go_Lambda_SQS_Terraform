terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = local.envs["REGION"]
}

provider "archive" {}

//build sqs deadletter
resource "aws_sqs_queue" "sqs_deadletter" {
  name                      = local.envs["SQS_DL"]
  delay_seconds             = 10
  max_message_size          = 1024
  message_retention_seconds = 300
  receive_wait_time_seconds = 10
}

//build sqs1
resource "aws_sqs_queue" "sqs1" {
  name                      = local.envs["SQS_1_NAME"]
  delay_seconds             = 10
  max_message_size          = 1024
  message_retention_seconds = 300
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.sqs_deadletter.arn}\",\"maxReceiveCount\":2}"
}

//build sqs2
resource "aws_sqs_queue" "sqs2" {
  name                      = local.envs["SQS_2_NAME"]
  delay_seconds             = 10
  max_message_size          = 1024
  message_retention_seconds = 300
  receive_wait_time_seconds = 10
  redrive_policy            = "{\"deadLetterTargetArn\":\"${aws_sqs_queue.sqs_deadletter.arn}\",\"maxReceiveCount\":2}"
}

// archive lambda go code
data "archive_file" "zip" {
  type        = "zip"
  source_file = "../lambda-handler/bin/main"
  output_path = "lambda_func.zip"
}


// build lambda function
resource "aws_lambda_function" "lambda_func" {
  function_name    = local.envs["LAMBDA_NAME"]
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  role    = aws_iam_role.lambda_exec.arn
  handler = "main"
  runtime = "go1.x"
  environment {
    variables = {
      REGION     = local.envs["REGION"]
      ACCOUNT_ID = local.envs["ACCOUNT_ID"]
      SQS_1_NAME = local.envs["SQS_1_NAME"]
      SQS_2_NAME = local.envs["SQS_2_NAME"]
    }
  }
}

// lambda subscribe for sqd
resource "aws_lambda_event_source_mapping" "subscribe_to_sqs1" {
  event_source_arn = aws_sqs_queue.sqs1.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_func.arn
  batch_size       = 1
}
