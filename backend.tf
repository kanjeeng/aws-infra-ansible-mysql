# ==========================================
# File: backend.tf
# Deskripsi: Remote Backend S3 & DynamoDB Lock
# ==========================================
terraform {
  backend "s3" {    # Remote Backend: Menyimpan state secara aman di cloud (S3)
    bucket         = "kanjeeng-tfstate-bucket-setup-env-ansible-mysql" # Remote Backend Bucket: Nama bucket S3 untuk menyimpan state
    key            = "aws-infra-dev/terraform.tfstate" # Path to state file in S3 bucket
    region         = "ap-southeast-1" # Remote Backend Region: Menentukan region S3 untuk menyimpan state
    dynamodb_table = "terraform-locks" # State Locking: Menggunakan DynamoDB untuk mencegah race condition/bentrok
    encrypt        = true # Enable encryption at rest
  }
}