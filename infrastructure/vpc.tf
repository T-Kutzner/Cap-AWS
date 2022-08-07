resource "aws_vpc" "server_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Server_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.server_vpc.id
}

resource "aws_subnet" "publicsubnet1" {
    vpc_id = aws_vpc.server_vpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "us-west-2a"
}

resource "aws_subnet" "publicsubnet2" {
    vpc_id = aws_vpc.server_vpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "us-west-2b"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.server_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.publicsubnet1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.publicsubnet2.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "vpc_access" {
  name        = "allowport80"
  description = "allow port 80"
  vpc_id      = aws_vpc.server_vpc.id
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "port80"
  }
}