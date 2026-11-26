output "site_url" {
  description = "HTTPS URL of the CloudFront-served static site."
  value       = "https://${aws_cloudfront_distribution.site.domain_name}"
}

output "cloudfront_distribution_id" {
  description = "CloudFront distribution ID, useful for cache invalidation."
  value       = aws_cloudfront_distribution.site.id
}

output "site_bucket_name" {
  description = "Name of the private S3 origin bucket."
  value       = aws_s3_bucket.site.id
}
