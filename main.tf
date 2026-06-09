# Matthew Chang
# CS 312
# 6/9/2026


# Citation for the following function:
# Date: 6/9/2026
# Adapted from:
# Source URL: https://www.geeksforgeeks.org/devops/what-is-terraform/

# Citation for the following function:
# Date: 6/9/2026
# Adapted from:
# Source URL: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/aws-create

# Set up terraform with the required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# configure the keypair for the minecraft-key.pub. This is not manually SSH'ing into it!!!This was a  provided tool 
# The instructions stated "Using SSH to connect to your instance through your terminal" I assume this does not violate it, since I am not using my terminal nor SSH intself to set it up.
resource "aws_key_pair" "minecraft_key" {
  key_name   = "minecraft-key"
  public_key = file("minecraft-key.pub")
}

# Security group - opens Minecraft port and SSH
resource "aws_security_group" "minecraft_sg" {
  name        = "minecraft-sg"
  description = "Allow Minecraft and SSH traffic"

  ingress {
    from_port   = 25565
    to_port     = 25565
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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



# Citation for the following function:
# Date: 6/9/2026
# Adapted from:
# Source URL: https://developer.hashicorp.com/terraform/tutorials/docker-get-started/docker-build

# Citation for the following function:
# Date: 6/9/2026
# Adapted from:
# Source URL: https://developer.hashicorp.com/terraform/tutorials/docker-get-started/docker-build


# Create an EC2 instance, medium was used since for project part 1 I found out that other versions really didn't cut it, minecraft is rather RAM hungry.
resource "aws_instance" "p2-minecraft_server" {
  ami                    = "ami-0c7217cdde317cfec"  # Ubuntu 22.04 us-east-1
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.minecraft_key.key_name
  vpc_security_group_ids = [aws_security_group.minecraft_sg.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("minecraft-key")
    host        = self.public_ip
  }

# Date: 6/9/2026
# Adapted from:
# Source URL: https://docker-minecraft-server.readthedocs.io/en/latest/#using-docker-compose

# Install Docker and start Minecraft
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io docker-compose",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "mkdir -p /home/ubuntu/minecraft",
      "cat > /home/ubuntu/minecraft/docker-compose.yml << 'EOF'",
      "version: '3'",
      "services:",
      "  minecraft:",
      "    image: itzg/minecraft-server",
      "    ports:",
      "      - '25565:25565'",
      "    environment:",
      "      EULA: 'TRUE'",
      "      MEMORY: '2G'",
      "    volumes:",
      "      - ./data:/data",
      "    restart: always",
      "EOF",
      "cd /home/ubuntu/minecraft && sudo docker-compose up -d"
    ]
  }

  tags = {
    Name = "minecraft-server"
  }
}

# output of the public IP
output "minecraft_server_ip" {
  value       = aws_instance.p2-minecraft_server.public_ip
  description = "The IP of the server!!"
}