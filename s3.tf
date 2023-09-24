resource "aws_s3_bucket" "turbo-waffle" {
  bucket_prefix = var.project_name
}
