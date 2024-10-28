variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "vpc_cidr" {
  description = "CIDR block for main VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for main subnet"
  type        = string
  default     = "10.100.1.0/24"
}

variable "other_vpc_cidr" {
  description = "CIDR block for the peered VPC"
  type        = string
  default     = "10.200.0.0/16"
}

variable "other_subnet_cidr" {
  description = "CIDR block for the subnet in the peered VPC"
  type        = string
  default     = "10.200.1.0/24"
}
