locals {
  arn_lambda = format("arn:aws:lambda:%s:%s", local.envs["REGION"], local.envs["ACCOUNT_ID"])
}
