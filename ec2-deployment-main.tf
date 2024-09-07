provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}


resource "aws_instance" "vm1" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Security group for allowing SSH access
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = var.instance_name
  }

  # Output the public IP of the instance after creation
  provisioner "local-exec" {
    command = "echo 'EC2 Instance created with public IP: ${self.public_ip}'"
  }
}


resource "aws_instance" "vm2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  # Security group for allowing SSH access
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = var.instance_name2
  }

  # Output the public IP of the instance after creation
  provisioner "local-exec" {
    command = "echo 'EC2 Instance created with public IP: ${self.public_ip}'"
  }
}
# Security group allowing SSH
resource "aws_security_group" "ssh_access" {
  name        = "${var.instance_name}-sg"
  description = "Allow SSH access"

  ingress {
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

# Key pair for SSH access
resource "aws_key_pair" "generated_key" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub") # Ensure this key exists locally
}
