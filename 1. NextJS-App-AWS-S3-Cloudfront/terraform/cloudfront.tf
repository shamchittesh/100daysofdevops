/*
Sets up a CloudFront distribution to serve the statuc app globally using AWS’s CDN.
•	origin: Connects the CloudFront distribution to the S3 bucket.
•	domain_name: Specifies the bucket’s regional domain.
•	origin_access_identity: Secures access to S3, preventing direct access from the public.
•	default_root_object: Sets index.html as the default page for the root URL.
•	default_cache_behavior: Defines how files are served:
•	viewer_protocol_policy: Redirects HTTP traffic to HTTPS.
•	allowed_methods: Restricts methods to GET and HEAD (safe for static content).
•	cookies: Specifies no cookies are forwarded.
•	viewer_certificate: Uses the default CloudFront SSL certificate for HTTPS.
*/

resource "aws_cloudfront_distribution" "nextjs_distribution" {
  origin {
    domain_name = aws_s3_bucket.nextjs_bucket.bucket_regional_domain_name
    origin_id   = "S3-nextjs-origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.nextjs_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id       = "S3-nextjs-origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "NextJSCloudFrontDistribution"
  }
}

/*
Creates an Origin Access Identity (OAI) to secure the S3 bucket.
CloudFront uses this identity to access the bucket, ensuring files are served only via CloudFront.
*/

resource "aws_cloudfront_origin_access_identity" "nextjs_identity" {
  comment = "OAI for Next.js S3 Bucket"
}