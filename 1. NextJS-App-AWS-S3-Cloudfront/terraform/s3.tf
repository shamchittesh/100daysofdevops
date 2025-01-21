/*
Creates an S3 bucket to store the static files.
acl: Sets permissions for the bucket. public-read allows public access to the files.
website: Configures the bucket to act as a static website.:
•	index_document: The default page (e.g., index.html).
•	error_document: A fallback page for 404 errors.
*/

resource "aws_s3_bucket" "nextjs_bucket" {
 bucket = "my-nextjs-app-bucket2" 
}


resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "publiceaccess" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.ownership,
    aws_s3_bucket_public_access_block.publiceaccess,
  ]

  bucket = aws_s3_bucket.nextjs_bucket.id
  acl    = "public-read"
}

/* 
Adds a policy to the bucket to allow public access to the files.
	•	Effect: Allow: Grants permission to perform the specified actions.
	•	Principal: *: anyone can access the files.
	•	Action: s3:GetObject: Allows reading objects in the bucket.
	•	Resource: Targets all files in the bucket.
*/

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.nextjs_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
resource "aws_s3_bucket_policy" "public_read_access" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
   "Principal": "*",
      "Action": [ "s3:GetObject" ],
      "Resource": [
        "${aws_s3_bucket.nextjs_bucket.arn}",
        "${aws_s3_bucket.nextjs_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}
