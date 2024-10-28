output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main_vpc.id
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = aws_subnet.main_subnet.id
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main_igw.id
}

output "security_group_id" {
  description = "The ID of the Security Group"
  value       = aws_security_group.main_sg.id
}

output "network_acl_id" {
  description = "The ID of the Network ACL"
  value       = aws_network_acl.main_acl.id
}

output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.guardduty.id
}
