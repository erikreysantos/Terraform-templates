provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Security Group for EC2 and Load Balancer
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP and SSH traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all outbound traffic
  }
}

# EC2 Instance in Availability Zone 1
resource "aws_instance" "web_ui_1" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
  availability_zone = "ap-southeast-1a"
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<html><h1>Web UI Instance 1 (AZ1)</h1></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "WebUI-Instance-1"
  }
}

# EC2 Instance in Availability Zone 2
resource "aws_instance" "web_ui_2" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  key_name      = var.key_name
  availability_zone = "ap-southeast-1b"
  security_groups = [aws_security_group.web_sg.name]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install -y httpd
              sudo systemctl start httpd
              sudo systemctl enable httpd
              echo "<html><h1>Web UI Instance 2 (AZ2)</h1></html>" > /var/www/html/index.html
              EOF

  tags = {
    Name = "WebUI-Instance-2"
  }
}

# Application Load Balancer (ALB)
resource "aws_lb" "web_lb" {
  name               = "web-ui-lb"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = var.public_subnets  # Ensure correct subnets
}

# Target Group for the EC2 Instances
resource "aws_lb_target_group" "web_tg" {
  name     = "web-ui-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id  # Ensure correct VPC ID
}

# Attach EC2 Instance 1 to Target Group
resource "aws_lb_target_group_attachment" "web_ui_1_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_ui_1.id
  port             = 80
}

# Attach EC2 Instance 2 to Target Group
resource "aws_lb_target_group_attachment" "web_ui_2_tg_attachment" {
  target_group_arn = aws_lb_target_group.web_tg.arn
  target_id        = aws_instance.web_ui_2.id
  port             = 80
}

# Listener for Load Balancer
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_tg.arn
  }
}

# Output the Load Balancer DNS Name
output "load_balancer_dns" {
  value = aws_lb.web_lb.dns_name
}

# Key pair for SSH access
resource "aws_key_pair" "generated_key" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub") # Ensure this key exists locally
}