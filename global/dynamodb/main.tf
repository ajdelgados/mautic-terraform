resource "aws_dynamodb_table" "terraform_state_lock" {
  name = "tf-aws-us-east-1.om"
  hash_key = "LockID"
  billing_mode     = "PAY_PER_REQUEST"
 
  attribute {
    name = "LockID"
    type = "S"
  }
}
