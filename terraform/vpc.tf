resource "aws_vpc" "ec2_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    "Name" = "k8s_vpc"
  }
}

resource "aws_subnet" "ec2_subnet" {
  vpc_id = aws_vpc.ec2_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = var.availability_zone
  map_public_ip_on_launch = true
  tags = {
    "Name" = "k8s_subnet"
  }
}

/*resource "aws_subnet" "ec2_subnet_db_1" {
  vpc_id = aws_vpc.ec2_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "ec2_subnet_db_1"
  }
}

resource "aws_subnet" "ec2_subnet_db_2" {
  vpc_id = aws_vpc.ec2_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "ec2_subnet_db_2"
  }
}*/

resource "aws_internet_gateway" "ec2_i_gateway" {
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    "name" = "k8s_i_gateway"
  }
}

resource "aws_route_table" "ec_route_table" {
  vpc_id = aws_vpc.ec2_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2_i_gateway.id
  }

  tags = {
    "name" = "k8s_route_table"
  }
}

resource "aws_route_table_association" "ec_rt_association" {
  route_table_id = aws_route_table.ec_route_table.id
  subnet_id = aws_subnet.ec2_subnet.id
}
