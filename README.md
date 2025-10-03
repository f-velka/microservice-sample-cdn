# microservice-sample-cdn

```bash
terraform init
ARN=$(aws ssm get-parameter --name /sample/function/arn --with-decryption --query 'Parameter.Value' --output text)
URL=$(aws ssm get-parameter --name /sample/function/url --with-decryption --query 'Parameter.Value' --output text)

terraform plan -var "lambda_function_arn=${ARN}" \
               -var "lambda_function_url=${URL}"

terraform apply -var "lambda_function_arn=${ARN}" \
                 -var "lambda_function_url=${URL}"
```
