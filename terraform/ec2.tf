# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script for application instances
locals {
  app_user_data = <<-EOF
    #!/bin/bash
    set -e
    
    # Update system
    dnf update -y
    
    # Install Node.js 18
    dnf install -y nodejs npm
    
    # Install Docker
    dnf install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker ec2-user
    
    # Install CodeDeploy agent
    dnf install -y ruby wget
    cd /home/ec2-user
    wget https://aws-codedeploy-${var.aws_region}.s3.${var.aws_region}.amazonaws.com/latest/install
    chmod +x ./install
    ./install auto
    systemctl start codedeploy-agent
    systemctl enable codedeploy-agent
    
    # Create application directory
    mkdir -p /var/www/app
    chown -R ec2-user:ec2-user /var/www/app
    
    # Install PM2 globally for process management
    npm install -g pm2
    
    echo "Instance setup completed" > /var/log/user-data.log
  EOF
}

# Blue Environment EC2 Instances
resource "aws_instance" "blue" {
  count                  = length(var.availability_zones)
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = local.app_user_data

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.project_name}-blue-${count.index + 1}"
    Environment = "blue"
    Application = "swiggy-clone"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Green Environment EC2 Instances
resource "aws_instance" "green" {
  count                  = length(var.availability_zones)
  ami                    = data.aws_ami.amazon_linux_2023.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public[count.index].id
  vpc_security_group_ids = [aws_security_group.app.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2.name

  user_data = local.app_user_data

  root_block_device {
    volume_size           = 20
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  tags = {
    Name        = "${var.project_name}-green-${count.index + 1}"
    Environment = "green"
    Application = "swiggy-clone"
  }

  lifecycle {
    create_before_destroy = true
  }
}
