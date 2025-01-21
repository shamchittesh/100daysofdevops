/* 
Output the CloudFront distribution’s URL after Terraform deploys the resources to test app 
*/

output "cloudfront_url" {
  value = aws_cloudfront_distribution.nextjs_distribution.domain_name
}