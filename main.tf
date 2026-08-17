# ------------------------------------------------------------------------------
# 1. PROVIDER CONFIGURATION
# ------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ------------------------------------------------------------------------------
# 2. NETWORK INFRASTRUCTURE (VPC, Subnet, Gateway, Route Table)
# ------------------------------------------------------------------------------
resource "aws_vpc" "capstone_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "tlab12-capstone-vpc"
    Environment = "Production"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.capstone_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "tlab12-public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.capstone_vpc.id

  tags = {
    Name = "tlab12-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.capstone_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tlab12-public-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ------------------------------------------------------------------------------
# 3. SECURITY GROUP (FIREWALL)
# ------------------------------------------------------------------------------
resource "aws_security_group" "web_sg" {
  name        = "tlab12-web-sg"
  description = "Security Group for Capstone Web Server with restricted access"
  vpc_id      = aws_vpc.capstone_vpc.id

  ingress {
    description = "Allow inbound HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tlab12-web-sg"
  }
}

# ------------------------------------------------------------------------------
# 4. COMPUTE (EC2 INSTANCE & USER DATA)
# ------------------------------------------------------------------------------
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "🛡️ TLAB 12: Capstone Web Application Live!Deployed securely via Terraform & GitHub Actions." > /var/www/html/index.html
              EOF

  metadata_options {
    http_tokens = "required"
  }

  root_block_device {
    encrypted = true
  }

  tags = {
    Name = "tlab12-capstone-web-server"
  }
}

# ------------------------------------------------------------------------------
# 5. OUTPUTS
# ------------------------------------------------------------------------------
output "web_public_ip" {
  description = "Public IP of the deployed Web Server"
  value       = aws_instance.web_server.public_ip
}

output "web_url" {
  description = "Direct URL to access the web app"
  value       = "http://${aws_instance.web_server.public_ip}"
}
