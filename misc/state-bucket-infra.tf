terraform {
  backend "local" {}
}

resource "aws_s3_bucket" "state_bucket" {
  bucket = "state-bucket-3480999"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "state_bucket_lock" {
  name           = "foostatelock"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
