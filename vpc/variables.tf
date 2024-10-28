# Define variables for the configuration
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1" 
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "10.100.1.0/24"
}

variable "other_vpc_cidr" {
  description = "CIDR block for the other VPC"
  type        = string
  default     = "10.200.0.0/16"
}
