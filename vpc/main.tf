# Main VPC
resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "MainVPC"
  }
}

# Subnet in Main VPC
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.subnet_cidr
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true
  tags = {
    Name = "MainSubnet"
  }
}

# Internet Gateway for Main VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainIGW"
  }
}

# Route Table for Main VPC
resource "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainRouteTable"
  }
}

# Route for Internet Gateway
resource "aws_route" "main_route" {
  route_table_id         = aws_route_table.main_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main_igw.id
}

# Associate Route Table with Main Subnet
resource "aws_route_table_association" "main_subnet_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_rt.id
}

# Security Group for Main VPC
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainSecurityGroup"
  }

  # Inbound rules
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NACL for Main VPC
resource "aws_network_acl" "main_nacl" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "MainNACL"
  }

  # Inbound Rules
  ingress {
    protocol   = "6" # TCP
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    protocol   = "6" # TCP
    rule_no    = 110
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 8080
    to_port    = 8080
  }

 # Ingress rule for ICMP (PING)
ingress {
  protocol   = "1"   # ICMP
  rule_no    = 120
  action     = "allow"
  cidr_block = "0.0.0.0/0"
  from_port  = 8     # ICMP type for echo request (Ping)
  to_port    = -1
}


  # Outbound Rules
  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

# "Other" VPC for Peering
resource "aws_vpc" "other_vpc" {
  cidr_block = var.other_vpc_cidr
  tags = {
    Name = "OtherVPC"
  }
}

# Private Subnet in Other VPC
resource "aws_subnet" "other_subnet" {
  vpc_id     = aws_vpc.other_vpc.id
  cidr_block = var.other_subnet_cidr
  tags = {
    Name = "OtherSubnet"
  }
}

# Route Table for Other VPC
resource "aws_route_table" "other_rt" {
  vpc_id = aws_vpc.other_vpc.id
  tags = {
    Name = "OtherRouteTable"
  }
}

# Associate Route Table with Other Subnet
resource "aws_route_table_association" "other_subnet_association" {
  subnet_id      = aws_subnet.other_subnet.id
  route_table_id = aws_route_table.other_rt.id
}

# VPC Peering Connection
resource "aws_vpc_peering_connection" "peer_connection" {
  vpc_id        = aws_vpc.main_vpc.id
  peer_vpc_id   = aws_vpc.other_vpc.id
  peer_region   = var.region
  tags = {
    Name = "Main-Other-VPC-Peering"
  }
}

# Route in Main VPC for Peering
resource "aws_route" "main_to_other_route" {
  route_table_id         = aws_route_table.main_rt.id
  destination_cidr_block = var.other_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}

# Route in Other VPC for Peering
resource "aws_route" "other_to_main_route" {
  route_table_id         = aws_route_table.other_rt.id
  destination_cidr_block = var.vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer_connection.id
}
