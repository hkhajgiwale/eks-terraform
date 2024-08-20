# Configure the S backend
terraform {
  backend "s3" {
    bucket  = "terraform-backend-harsh"
    key     = "eks/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
    profile = "terraform"
  }
}
