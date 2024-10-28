# Output VPC IDs
output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "other_vpc_id" {
  value = aws_vpc.other_vpc.id
}

# Output Security Group ID
output "main_security_group_id" {
  value = aws_security_group.main_sg.id
}

# Output Route Table IDs
output "main_route_table_id" {
  value = aws_route_table.main_route_table.id
}

output "other_vpc_route_table_id" {
  value = aws_route_table.other_vpc_route_table.id
}
