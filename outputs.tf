output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution."
  value       = aws_cloudfront_distribution.this.arn
}

output "cloudfront_domain_name" {
  description = "Domain name assigned by CloudFront."
  value       = aws_cloudfront_distribution.this.domain_name
}

output "origin_access_control_id" {
  description = "ID of the CloudFront origin access control."
  value       = aws_cloudfront_origin_access_control.lambda.id
}
