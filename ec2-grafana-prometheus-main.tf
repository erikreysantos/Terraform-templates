provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Security group for Grafana and Prometheus (allows HTTP and SSH)
resource "aws_security_group" "grafana_sg" {
  name        = "grafana_sg"
  description = "Allow inbound traffic for Grafana, Prometheus, and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9090  # Prometheus default port
    to_port     = 9090
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

# EC2 Instance for Grafana and Prometheus
resource "aws_instance" "grafana" {
  ami           = var.ami_id  # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  key_name      = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }

    inline = [
      "sudo yum update -y",
      
      # Install Grafana
      "sudo tee /etc/yum.repos.d/grafana.repo <<EOF",
      "[grafana]",
      "name=grafana",
      "baseurl=https://packages.grafana.com/oss/rpm",
      "repo_gpgcheck=1",
      "enabled=1",
      "gpgcheck=1",
      "gpgkey=https://packages.grafana.com/gpg.key",
      "EOF",
      "sudo yum install -y grafana",
      "sudo systemctl start grafana-server",
      "sudo systemctl enable grafana-server",
      
      # Install firewalld
      "sudo yum install -y firewalld",
      "sudo systemctl start firewalld",
      "sudo systemctl enable firewalld",
      "sudo firewall-cmd --permanent --add-port=3000/tcp",  # Allow Grafana
      "sudo firewall-cmd --permanent --add-port=9090/tcp",  # Allow Prometheus
      "sudo firewall-cmd --reload",

      # Install Prometheus
      "cd /opt",
      "sudo wget https://github.com/prometheus/prometheus/releases/download/v2.29.1/prometheus-2.29.1.linux-amd64.tar.gz",
      "sudo tar xvf prometheus-2.29.1.linux-amd64.tar.gz",
      "sudo mv prometheus-2.29.1.linux-amd64 prometheus",
      "sudo useradd --no-create-home --shell /bin/false prometheus",
      "sudo chown -R prometheus:prometheus /opt/prometheus",
      
      # Create Prometheus service file
      "sudo tee /etc/systemd/system/prometheus.service <<EOF",
      "[Unit]",
      "Description=Prometheus",
      "Wants=network-online.target",
      "After=network-online.target",
      "[Service]",
      "User=prometheus",
      "ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data",
      "[Install]",
      "WantedBy=multi-user.target",
      "EOF",
      
      # Start and enable Prometheus service
      "sudo systemctl daemon-reload",
      "sudo systemctl start prometheus",
      "sudo systemctl enable prometheus"
    ]
  }

  tags = {
    Name = "grafana-prometheus-instance"
  }
}

# Key pair for SSH access
resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = file(var.public_key_path)
}

# Output Grafana and Prometheus URLs
output "grafana_url" {
  value = "http://${aws_instance.grafana.public_ip}:3000"
}

output "prometheus_url" {
  value = "http://${aws_instance.grafana.public_ip}:9090"
}
