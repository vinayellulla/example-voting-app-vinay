resource "aws_vpc" "solid_vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "sub1" {
  vpc_id                  = aws_vpc.solid_vpc.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true


  tags = {
    "kubernetes.io/role/elb"           = "1"
    "kubernetes.io/cluster/voting-app" = "shared"
  }

}

resource "aws_subnet" "sub2" {
  vpc_id                  = aws_vpc.solid_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    "kubernetes.io/role/elb"           = "1"
    "kubernetes.io/cluster/voting-app" = "shared"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.solid_vpc.id
}

resource "aws_route_table" "solid-RT" {
  vpc_id = aws_vpc.solid_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "rta-1" {
  subnet_id      = aws_subnet.sub1.id
  route_table_id = aws_route_table.solid-RT.id
}


resource "aws_route_table_association" "rta-2" {
  subnet_id      = aws_subnet.sub2.id
  route_table_id = aws_route_table.solid-RT.id
}







