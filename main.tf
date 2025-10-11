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

# Public Subnet for AZ 1
resource "aws_subnet" "skyline_public_az1" {
  vpc_id = aws_vpc.skyline_vpc.id
  cidr_block = "12.0.0.0/26"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.skyline_az.names[0]

  tags = {
    Name = "skyline-public-az1"
  }
}

# Private Subnet for AZ 1
resource "aws_subnet" "skyline_private_az1" {
  vpc_id = aws_vpc.skyline_vpc.id
  cidr_block = "12.0.0.64/26"
  availability_zone = data.aws_availability_zones.skyline_az.names[0]

  tags = {
    Name = "skyline-private-az1"
  }
}

# Public Subnet for AZ 2
resource "aws_subnet" "skyline_public_az2" {
  vpc_id = aws_vpc.skyline_vpc.id
  cidr_block = "12.0.0.128/26"
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.skyline_az.names[1]

  tags = {
    Name = "skyline-public-az2"
  }
}

# Private Subnet for AZ 2
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

# Public Subnets Route Table
resource "aws_route_table" "skyline_public_rt" {
  vpc_id = aws_vpc.skyline_vpc.id

  tags = {
    Name = "skyline-public-rt"
  }
}

# Public Subnet Route
resource "aws_route" "skyline_public_route" {
  route_table_id = aws_route_table.skyline_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.skyline_igw.id
}

# Public Subnet Route Association for AZ 1
resource "aws_route_table_association" "skyline_public_rta1" {
  subnet_id = aws_subnet.skyline_public_az1.id
  route_table_id = aws_route_table.skyline_public_rt.id
}

# Public Subnet Route Association for AZ 2
resource "aws_route_table_association" "skyline_public_rta2" {
  subnet_id = aws_subnet.skyline_public_az2.id
  route_table_id = aws_route_table.skyline_public_rt.id
}

# Elastic IP for NAT Gateway 1
resource "aws_eip" "skyline_nat_ip1" {
  domain = "vpc"

  tags = {
    Name = "skyline-nat-ip1"
  }
}

# Elastic IP for NAT Gateway 2
resource "aws_eip" "skyline_nat_ip2" {
  domain = "vpc"

  tags = {
    Name = "skyline-nat-ip2"
  }
}

# NAT Gateway for AZ 1
resource "aws_nat_gateway" "skyline_nat_az1" {
  allocation_id = aws_eip.skyline_nat_ip1.id
  subnet_id = aws_subnet.skyline_private_az1.id
  depends_on = [ aws_internet_gateway.skyline_igw ]

  tags = {
    Name = "skyline-nat-az1"
  }
}

# NAT Gateway for AZ 2
resource "aws_nat_gateway" "skyline_nat_az2" {
  allocation_id = aws_eip.skyline_nat_ip2.id
  subnet_id = aws_subnet.skyline_private_az2.id
  depends_on = [ aws_internet_gateway.skyline_igw ]

  tags = {
    Name = "skyline-nat-az2"
  }
}

# Private Subnet Route Table for AZ 1
resource "aws_route_table" "skyline_private_rt_az1" {
  vpc_id = aws_vpc.skyline_vpc.id

  tags = {
    Name = "skyline-private-rt-az1"
  }
}

# Private Subnet Route with NAT Gateway 1 for AZ 1
resource "aws_route" "skyline_private_route_az1" {
  route_table_id = aws_route_table.skyline_private_rt_az1.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.skyline_nat_az1.id
}

# Private Subnet Route Association for AZ 1
resource "aws_route_table_association" "skyline_private_rta_az1" {
  subnet_id = aws_subnet.skyline_private_az1.id
  route_table_id = aws_route_table.skyline_private_rt_az1.id
}

# Private Subnet Route Table for AZ 2
resource "aws_route_table" "skyline_private_rt_az2" {
  vpc_id = aws_vpc.skyline_vpc.id

  tags = {
    Name = "skyline-private-rt-az2"
  }
}

# Private Subnet Route with NAT Gateway 2 for AZ 2
resource "aws_route" "skyline_private_route_az2" {
  route_table_id = aws_route_table.skyline_private_rt_az2.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.skyline_nat_az2.id
}

# Private Subnet Route Association for AZ 2
resource "aws_route_table_association" "skyline_private_rta_az2" {
  subnet_id = aws_subnet.skyline_private_az2.id
  route_table_id = aws_route_table.skyline_private_rt_az2.id
}