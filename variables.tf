variable "lambda_function_url" {
  description = "Lambda Function URL that CloudFront should call. Accepts the full https URL or just the host name."
  type        = string
}

variable "lambda_function_arn" {
  description = "ARN of the Lambda function associated with the Function URL. Used to grant CloudFront invoke permissions."
  type        = string
}
