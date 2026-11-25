resource "aws_s3_bucket" "sensitive" {
  bucket        = "${local.name_prefix}-customer-records"
  force_destroy = true # lab only: lets `terraform destroy` empty the bucket

  tags = {
    Name               = "${local.name_prefix}-customer-records"
    DataClassification = "confidential"
  }
}

# The bucket itself is NOT public. The exposure comes through the public EC2 instance's role.
resource "aws_s3_bucket_public_access_block" "sensitive" {
  bucket                  = aws_s3_bucket.sensitive.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# SSE-S3 (AES256), not KMS, so the Datadog Agentless scanner can read objects without key grants.
resource "aws_s3_bucket_server_side_encryption_configuration" "sensitive" {
  bucket = aws_s3_bucket.sensitive.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# INTENTIONAL: no versioning, no access logging, no object lock -> CSPM S3 findings

resource "aws_s3_object" "customer_records" {
  bucket       = aws_s3_bucket.sensitive.id
  key          = "exports/customer_records.txt"
  source       = "${path.module}/../data/customer_records.txt"
  etag         = filemd5("${path.module}/../data/customer_records.txt")
  content_type = "text/plain"
}
