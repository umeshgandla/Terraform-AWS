
# Create the main VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Main-VPC"
  }
}

# Create Subnet within the main VPC
resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.subnet_cidr
  availability_zone       = "us-east-2a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Main-Subnet"
  }
}

# Create an Internet Gateway and attach it to the main VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Main-IGW"
  }
}

# Create a route table for the main VPC and add default route through IGW
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Main-Route-Table"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.main_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate the route table with the subnet
resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.main_route_table.id
}

# Security Group allowing specific inbound and outbound traffic
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Main-SG"
  }

  # Inbound rules
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
  ingress {
    from_port   = -1  # ICMP (ping)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a private VPC for peering connection
resource "aws_vpc" "other_vpc" {
  cidr_block = var.other_vpc_cidr
  tags = {
    Name = "Other-VPC"
  }
}

# Peering connection between main VPC and other VPC
resource "aws_vpc_peering_connection" "vpc_peering" {
  vpc_id        = aws_vpc.main_vpc.id
  peer_vpc_id   = aws_vpc.other_vpc.id
  auto_accept   = true
  tags = {
    Name = "Main-Other-VPC-Peering"
  }
}

# Route table entries for peering connection
resource "aws_route" "main_vpc_to_other" {
  route_table_id         = aws_route_table.main_route_table.id
  destination_cidr_block = aws_vpc.other_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route_table" "other_vpc_route_table" {
  vpc_id = aws_vpc.other_vpc.id
  tags = {
    Name = "Other-VPC-Route-Table"
  }
}

resource "aws_route" "other_vpc_to_main" {
  route_table_id         = aws_route_table.other_vpc_route_table.id
  destination_cidr_block = aws_vpc.main_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

# Network ACL for the main VPC to allow SSH, HTTP 8080, and ICMP (Ping)
resource "aws_network_acl" "main_acl" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "Main-VPC-NACL"
  }

  # Inbound rules
  ingress {
    protocol    = "6"  # TCP
    rule_no     = 100
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 22
    to_port     = 22
  }
  ingress {
    protocol    = "6"  # TCP
    rule_no     = 110
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 8080
    to_port     = 8080
  }
  ingress {
    protocol    = "1"  # ICMP
    rule_no     = 120
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = -1
    to_port     = -1
  }

  # Outbound rules
  egress {
    protocol    = "-1"
    rule_no     = 100
    action      = "allow"
    cidr_block  = "0.0.0.0/0"
    from_port   = 0
    to_port     = 0
  }
}
