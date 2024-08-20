# Data source to get the current AWS account ID
data "aws_caller_identity" "current" {}

# Data source to get the current AWS region
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_eks_cluster_auth" "eks_cluster" {
  name = "eks-cluster"
}