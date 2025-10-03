# microservice-sample-cdn

```bash
terraform init
terraform plan -var "lambda_function_arn=arn:aws:lambda:ap-northeast-1:123456789012:function:example" \
               -var "lambda_function_url=https://abcd1234.lambda-url.ap-northeast-1.on.aws/"
terraform apply
```
