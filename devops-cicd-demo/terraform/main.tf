provider "aws" {
  region = "us-east-1"
}

variable "key_pair_name" {
  type        = string
  default     = "devops-demo-key"
  description = "The name of the AWS SSH key pair"
}

resource "aws_security_group" "demo_sg" {
  name        = "devops-demo-sg"
  description = "Allow SSH and App Traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "app_server" {
  ami           = "ami-04b70fa74e45c3917" # Clean Ubuntu 22.04 LTS in us-east-1
  instance_type = "t2.micro"
  key_name      = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.demo_sg.id]

  tags = {
    Name = "DevOps-CICD-Demo-Server"
  }
}

output "public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP address of the main server instance."
}

output "instance_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "The public IP address matching the script expectations."
}
