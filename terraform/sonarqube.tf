# SonarQube EC2 Instance
resource "aws_instance" "sonarqube" {
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.sonarqube_instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.sonarqube.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    dnf update -y
    
    # Install Java 17 (required for SonarQube)
    dnf install -y java-17-amazon-corretto-headless
    
    # Install Docker
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
    
    # Set system limits for SonarQube
    cat >> /etc/sysctl.conf <<EOL
vm.max_map_count=524288
fs.file-max=131072
EOL
    sysctl -p
    
    cat >> /etc/security/limits.conf <<EOL
sonarqube   -   nofile   131072
sonarqube   -   nproc    8192
EOL
    
    # Run SonarQube in Docker
    docker run -d \
      --name sonarqube \
      --restart unless-stopped \
      -p 9000:9000 \
      -e SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true \
      sonarqube:lts-community
    
    echo "SonarQube installation completed" > /var/log/sonarqube-setup.log
    echo "Access SonarQube at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9000"
    echo "Default credentials: admin/admin"
  EOF

  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.project_name}-sonarqube"
    Application = "SonarQube"
  }
}

# Elastic IP for SonarQube (optional but recommended)
resource "aws_eip" "sonarqube" {
  instance = aws_instance.sonarqube.id
  domain   = "vpc"

  tags = {
    Name = "${var.project_name}-sonarqube-eip"
  }

  depends_on = [aws_internet_gateway.main]
}
