# VPC
resource "aws_vpc" "main_vpc" {
  cidr_block       = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "Main-VPC"
  }
}

# Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "us-east-2a"  # Change to the appropriate AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "Main-Subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "Main-IGW"
  }
}

# Route Table
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }

  tags = {
    Name = "Main-Route-Table"
  }
}

# Route Table Association
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# Security Group
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    description = "Allow PING"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow App HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Main-SG"
  }
}

# Network ACL
resource "aws_network_acl" "main_acl" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    rule_no    = 100
    protocol   = "6" # TCP
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 22
    to_port    = 22
  }

  ingress {
    rule_no    = 110
    protocol   = "6" # TCP
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 8080
    to_port    = 8080
  }

  ingress {
    rule_no    = 120
    protocol   = "1" # ICMP for ping
    action     = "allow"
    cidr_block = "0.0.0.0/0"
  }

  egress {
    rule_no    = 100
    protocol   = "-1" # All protocols
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "Main-NACL"
  }
}

# VPC Peering (between main VPC and other VPC)
resource "aws_vpc_peering_connection" "peer" {
  vpc_id        = aws_vpc.main_vpc.id
  peer_vpc_id   = aws_vpc.other_vpc.id
  auto_accept   = true

  tags = {
    Name = "Main-Other-VPC-Peering"
  }
}


