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

# Bastion Host Security Group
resource "aws_security_group" "skyline_bastion_sg" {
  name = "skyline_bastion_sg"
  description = "Allow SSH into Bastion Host"
  vpc_id = aws_vpc.skyline_vpc.id

  tags = {
    Name = "skyline-bastion-sg"
  }
}

# Bastion Host Security Group Ingress Rule
resource "aws_vpc_security_group_ingress_rule" "skyline_bastion_ir" {
  security_group_id = aws_security_group.skyline_bastion_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

# Bastion Host Security Group Egress Rule
resource "aws_vpc_security_group_egress_rule" "skyline_bastion_er" {
  security_group_id = aws_security_group.skyline_bastion_sg.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = "-1"
}

# ALB Security Group
resource "aws_security_group" "skyline_alb_sg" {
  name = "skyline_alb_sg"
  description = "Allow Traffic from the Internet"
  vpc_id = aws_vpc.skyline_vpc.id

  tags = {
    Name = "skyline-alb-sg"
  }
}

# ALB Security Group Ingress Rule
resource "aws_security_group_rule" "skyline_alb_ir" {
  security_group_id = aws_security_group.skyline_alb_sg.id
  type = "ingress"
  cidr_blocks = [ "0.0.0.0/0" ]
  protocol = "tcp"
  from_port = 80
  to_port = 80
}

# ALB Security Group Egress Rule
resource "aws_security_group_rule" "skyline_alb_er" {
  security_group_id = aws_security_group.skyline_alb_sg.id
  type = "egress"
  protocol = "tcp"
  from_port = 80
  to_port = 80
  source_security_group_id = aws_security_group.skyline_ec2_sg.id
}

# EC2 Security Group
resource "aws_security_group" "skyline_ec2_sg" {
  name = "skyline_ec2_sg"
  description = "Allow Bastion SSH, ALB and Docker Swarm"
  vpc_id = aws_vpc.skyline_vpc.id

  tags = {
    Name = "skyline-ec2-sg"
  }
}

# EC2 Security Group Ingress Rule for Bastion SSH
resource "aws_security_group_rule" "skyline_ec2_ssh_ir" {
  security_group_id = aws_security_group.skyline_ec2_sg.id
  type = "ingress"
  protocol = "tcp"
  from_port = 22
  to_port = 22
  source_security_group_id = aws_security_group.skyline_bastion_sg.id
}

# EC2 Security Group Ingress Rule for ALB Traffic
resource "aws_security_group_rule" "skyline_ec2_alb_ir" {
  security_group_id = aws_security_group.skyline_ec2_sg.id
  type = "ingress"
  protocol = "tcp"
  from_port = 80
  to_port = 80
  source_security_group_id = aws_security_group.skyline_alb_sg.id
}

# EC2 Security Group Ingress Rule for Docker Swarm Cluster Management
resource "aws_security_group_rule" "skyline_ec2_cm_ir" {
  security_group_id = aws_security_group.skyline_ec2_sg.id
  type = "ingress"
  protocol = "tcp"
  from_port = 2377
  to_port = 2377
  self = true       # Allow traffic from instances in the SAME security group
}

# EC2 Security Group Ingress Rule for Docker Swarm Node Communication (TCP)
resource "aws_security_group_rule" "skyline_ec2_nc_tcp_ir" {
  security_group_id = aws_security_group.skyline_ec2_sg.id
  type = "ingress"
  protocol = "tcp"
  from_port = 7946
  to_port = 7946
  self = true       # Allow traffic from instances in the SAME security group
}

# EC2 Security Group Ingress Rule for Docker Swarm Node Communication (UDP)
resource "aws_security_group_rule" "skyline_ec2_nc_udp_ir" {
  security_group_id = aws_security_group.skyline_ec2_sg.id
  type = "ingress"
  protocol = "udp"
  from_port = 7946
  to_port = 7946
  self = true       # Allow traffic from instances in the SAME security group
}

# EC2 Security Group Ingress Rule for Docker Swarm Overlay Network (UDP)
resource "aws_security_group_rule" "skyline_ec2_on_udp_ir" {
  security_group_id = aws_security_group.skyline_ec2_sg.id
  type = "ingress"
  protocol = "udp"
  from_port = 4789
  to_port = 4789
  self = true       # Allow traffic from instances in the SAME security group
}

# EC2 Security Group Egress Rule
resource "aws_security_group_rule" "skyline_ec2_er" {
  security_group_id = aws_security_group.skyline_ec2_sg.id
  type = "egress"
  protocol = "-1"
  from_port = 0
  to_port = 0
  cidr_blocks = [ "0.0.0.0/0" ]
}

# Launch Template for Auto Scaling Group
resource "aws_launch_template" "skyline_swarm_lt" {
  name = "skyline-swarm-"
  image_id = data.aws_ami.skyline_ami.id
  instance_type = var.skyline_instance_type
  key_name = var.skyline_key
  user_data = base64encode(file("${path.module}/userdata.tpl"))

  network_interfaces {
    associate_public_ip_address = false
    security_groups = [ aws_security_group.skyline_ec2_sg.id ]
    delete_on_termination = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "skyline-swarm-node"
      Role = "docker-swarm"
    }
  }

  tags = {
    Name = "skyline-swarm-lt"
  }
}

# Target Group to group EC2 for ALB
resource "aws_lb_target_group" "skyline_alb_tg" {
  name     = "skyline-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.skyline_vpc.id

  # Deregistration delay - wait before removing instance
  deregistration_delay = 30

  health_check {
    enabled = true
    healthy_threshold = 2      # 2 successful checks = healthy
    unhealthy_threshold = 3    # 3 failed checks = unhealthy
    timeout = 6                # 6 seconds to respond
    interval = 30              # Check every 30 seconds
    path = "/"                 # Health check endpoint
    matcher = "200"            # Expected HTTP response code
  }

  tags = {
    Name = "skyline-alb-tg"
  }
}

# Auto Scaling Group for HA and ALB
resource "aws_autoscaling_group" "skyline_asg" {
  name = "skyline-asg"
  max_size = 4
  min_size = 1
  desired_capacity = 2
  health_check_type = "ELB"   # Use ELB health checks instead of EC2
  health_check_grace_period = 300   # Wait 5 minutes before checking health

  # Wait for instances to be healthy before considering deployment successful
  wait_for_capacity_timeout = "10m"

  launch_template {
    id = aws_launch_template.skyline_swarm_lt.id
    version = "$Latest"
  }

  # Deploy instances in PRIVATE subnets only
  vpc_zone_identifier = [ aws_subnet.skyline_private_az1.id, aws_subnet.skyline_private_az2.id ]

  # Attach to the target group (for ALB)
  target_group_arns = [ aws_lb_target_group.skyline_alb_tg.arn ]

  # Lifecycle settings
  lifecycle {
    create_before_destroy = true
  }

  # Tags for instances launched by this ASG
  tag {
    key = "Name"
    value = "skyline-swarm"
    propagate_at_launch = true
  }

  tag {
    key = "Role"
    value = "docker-swarm"
    propagate_at_launch = true
  }
}