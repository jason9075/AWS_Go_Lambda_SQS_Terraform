# Deploy SQS -> Lambda -> SQS on AWS with Terraform

## Deploy
```
cd terraform
terraform apply
```

## Check Status
```
terraform show
```

## Send Message to SQS1
```
aws sqs send-message --queue-url $(terraform output sqs1_url) --region <region> --message-body "{message: \"hello, world\"}"
```

## Remove AWS Service
```
terraform destroy
```

# Golang Lambda

## Unit Test
```
go test -v -cover
```
