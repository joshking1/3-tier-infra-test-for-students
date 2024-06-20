provider "aws" {
  region = "us-east-1"  # Replace with your desired AWS region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "MainVPC"
  }
}

# Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone = "us-east-1a"  # Replace with desired AZ
  map_public_ip_on_launch = true

  tags = {
    Name = "PublicSubnet-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)
  availability_zone = "us-east-1b"  # Replace with desired AZ

  tags = {
    Name = "PrivateSubnet-${count.index}"
  }
}

# Security Groups
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id
  name   = "WebSecurityGroup"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  vpc_id = aws_vpc.main.id
  name   = "AppSecurityGroup"

  # Define rules for application tier
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id
  name   = "DBSecurityGroup"

  # Define rules for database tier
}

# Instances
resource "aws_instance" "web" {
  count         = 2
  ami           = "ami-0abc123456789def0"  # Replace with your desired AMI
  instance_type = "t2.micro"  # Replace with desired instance type
  subnet_id     = aws_subnet.public[count.index].id
  security_groups = [aws_security_group.web_sg.id]

  tags = {
    Name = "WebInstance-${count.index}"
  }
}

resource "aws_instance" "app" {
  count         = 2
  ami           = "ami-0abc123456789def0"  # Replace with your desired AMI
  instance_type = "t2.micro"  # Replace with desired instance type
  subnet_id     = aws_subnet.private[count.index].id
  security_groups = [aws_security_group.app_sg.id]

  tags = {
    Name = "AppInstance-${count.index}"
  }
}

resource "aws_instance" "db" {
  count         = 1
  ami           = "ami-0abc123456789def0"  # Replace with your desired AMI
  instance_type = "t2.micro"  # Replace with desired instance type
  subnet_id     = aws_subnet.private[0].id
  security_groups = [aws_security_group.db_sg.id]

  tags = {
    Name = "DBInstance"
  }
}
