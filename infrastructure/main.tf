resource "aws_s3_bucket" "sample_bucket" {
  bucket = "sample-bucket-for-terraform-state"
  object_lock_enabled = true

  lifecycle {
    prevent_destroy = true
  }
}