resource "aws_vpc" "skyline_vpc" {
  cidr_block = "12.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "skyline-vpc"
  }
}

data "aws_availability_zones" "skyline_az" {
  state = "available"
}

resource "aws_subnet" "skyline_public_az1" {
  vpc_id = aws_vpc.skyline_vpc.id
  cidr_block = "12.0.0.0/26"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.skyline_az.names[0]

  tags = {
    Name = "skyline-public-az1"
  }
}

resource "aws_subnet" "skyline_private_az1" {
  vpc_id = aws_vpc.skyline_vpc.id
  cidr_block = "12.0.0.64/26"
  availability_zone = data.aws_availability_zones.skyline_az.names[0]

  tags = {
    Name = "skyline-private-az1"
  }
}

resource "aws_subnet" "skyline_public_az2" {
  vpc_id = aws_vpc.skyline_vpc.id
  cidr_block = "12.0.0.128/26"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.skyline_az.names[1]

  tags = {
    Name = "skyline-public-az2"
  }
}

resource "aws_subnet" "skyline_private_az2" {
  vpc_id = aws_vpc.skyline_vpc.id
  cidr_block = "12.0.0.192/26"
  availability_zone = data.aws_availability_zones.skyline_az.names[1]

  tags = {
    Name = "skyline-private-az2"
  }
}

resource "aws_internet_gateway" "skyline_igw" {
  vpc_id = aws_vpc.skyline_vpc.id

  tags = {
    Name = "skyline-igw"
  }
}

resource "aws_route_table" "skyline_public_rt" {
  vpc_id = aws_vpc.skyline_vpc.id

  tags = {
    Name = "skyline-public-rt"
  }
}

resource "aws_route" "skyline_public_route" {
  route_table_id = aws_route_table.skyline_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.skyline_igw.id
}

resource "aws_route_table_association" "skyline_public_rta1" {
  subnet_id = aws_subnet.skyline_public_az1.id
  route_table_id = aws_route_table.skyline_public_rt.id
}

resource "aws_route_table_association" "skyline_public_rta2" {
  subnet_id = aws_subnet.skyline_public_az2.id
  route_table_id = aws_route_table.skyline_public_rt.id
}