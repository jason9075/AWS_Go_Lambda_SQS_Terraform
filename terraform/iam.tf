resource "aws_iam_role" "lambda_exec" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_exec" {
  policy_arn = aws_iam_policy.lambda_exec.arn
  role       = aws_iam_role.lambda_exec.name
}

resource "aws_iam_policy" "lambda_exec" {
  policy = data.aws_iam_policy_document.policy.json
}

// build role
data "aws_iam_policy_document" "policy" {
  statement {
    sid       = "AllowSQSPermissions"
    effect    = "Allow"
    resources = [aws_sqs_queue.sqs_deadletter.arn, aws_sqs_queue.sqs1.arn, aws_sqs_queue.sqs2.arn]
    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
    ]
  }

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = [format("%s:*:function:%s", local.arn_lambda, local.envs["LAMBDA_NAME"])]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = [format("arn:aws:logs:%s:*:*", local.envs["REGION"])]
    actions   = ["logs:CreateLogGroup"]
  }

  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = [format("arn:aws:logs:%s:*:log-group:/aws/lambda/*:*", local.envs["REGION"])]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

