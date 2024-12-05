provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "VPC_Ned" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC_Ned"
  }
}

resource "aws_subnet" "Subnet_Ned" {
  vpc_id                  = aws_vpc.VPC_Ned.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Subnet_Ned"
  }
}

resource "aws_internet_gateway" "IGW_Ned" {
  vpc_id = aws_vpc.VPC_Ned.id
  tags = {
    Name = "IGW_Ned"
  }
}

resource "aws_route_table" "RT_Ned" {
  vpc_id = aws_vpc.VPC_Ned.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_Ned.id
  }

  tags = {
    Name = "RT_Ned"
  }
}

resource "aws_route_table_association" "RTA_Ned" {
  subnet_id      = aws_subnet.Subnet_Ned.id
  route_table_id = aws_route_table.RT_Ned.id
}

resource "aws_security_group" "SG_Ned" {
  vpc_id = aws_vpc.VPC_Ned.id
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
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SG_Ned"
  }
}

resource "aws_instance" "Web_Ned" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 Free Tier
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.Subnet_Ned.id
  vpc_security_group_ids = [aws_security_group.SG_Ned.id]

  associate_public_ip_address = true

  user_data = file("${path.module}/user_data.sh")

  tags = {
    Name = "Web_Ned"
  }
}

