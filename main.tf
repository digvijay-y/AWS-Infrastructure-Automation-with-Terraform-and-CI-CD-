provider "aws" {
  region     = "ap-south-1"
  access_key = "AKIA2ZIO******"   
  secret_key = "E2lA+/********"
}

# Step 1: Create a VPC
resource "aws_vpc" "vpc_1" {
  cidr_block = "10.0.0.0/16"
}

# Step 2: Create an Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc_1.id
}

# Step 3: Create a Route Table
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc_1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Step 4: Create a Subnet
resource "aws_subnet" "subn" {
  vpc_id            = aws_vpc.vpc_1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    name = "prob-subnet"
  }
}

# Step 5: Associate Subnet to Route Table
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.subn.id
  route_table_id = aws_route_table.rt.id
}

# Step 6: Create Security Group to Allow Ports 22, 80, 443
resource "aws_security_group" "allow_web" {
  name        = "allow_web_traffic"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.vpc_1.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

# Step 7: Create Network Interface with an IP in the Subnet
resource "aws_network_interface" "web_server_nic" {
  subnet_id        = aws_subnet.subn.id
  private_ips       = ["10.0.1.50"]
  security_groups  = [aws_security_group.allow_web.id]
}

# Step 8: Assign Elastic IP to Network Interface
resource "aws_eip" "one" {
  domain                  = "vpc"  # Use "vpc" instead of the deprecated `vpc = true`
  network_interface       = aws_network_interface.web_server_nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on              = [aws_instance.first_server]  # Ensure the instance is up
}



# Step 9: Create Ubuntu Server and Install/Enable Apache2
resource "aws_instance" "first_server" {
  ami             = "ami-053b12d3152c0cc71"
  instance_type   = "t2.micro"
  availability_zone = "ap-south-1a"
  key_name        = "main-key"
  
  network_interface {
    device_index             = 0
    network_interface_id     = aws_network_interface.web_server_nic.id
  }

  user_data = <<-EOF
    #!/bin/bash
    sudo apt update -y
    sudo apt install apache2 -y
    sudo systemctl start apache2
    sudo bash -c "echo 'First web server' > /var/www/html/index.html"
  EOF

  tags = {
    Name = "Ubuntu_server"
  }
}

terraform {
  backend "s3" {
    bucket         = "digvijay-21122024"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "your-lock-table"
    encrypt        = true
  }
}  


output "server_private_ip" {
  value = aws_instance.first_server.private_ip
}

output "server_id" {
  value = aws_instance.first_server.id
}
