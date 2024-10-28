output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "other_vpc_id" {
  value = aws_vpc.other_vpc.id
}

output "main_subnet_id" {
  value = aws_subnet.main_subnet.id
}

output "other_subnet_id" {
  value = aws_subnet.other_subnet.id
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.peer_connection.id
}
