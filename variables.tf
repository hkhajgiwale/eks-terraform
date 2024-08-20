variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.1.4.0/24", "10.1.5.0/24"]
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  default     = ["10.1.7.0/24", "10.1.8.0/24"]
}

variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type        = string
  default     = "" # Optionally, set a default or leave empty to read from env
}

variable "aws_secret_access_key" {
  description = "AWS Secret Access Key"
  type        = string
  default     = "" # Optionally, set a default or leave empty to read from env
}
