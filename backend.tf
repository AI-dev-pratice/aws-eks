# Project 1 — EKS infrastructure
terraform {
  backend "s3" {
    bucket         = "terraform-aws-tf-state-bucket-1"
    key            = "projects/eks/production/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "aws-tf-lock-table"
    encrypt        = true
  }
}