# VPCssh 
resource "aws_vpc" "k3s_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "k3s_vpc"
    Env     = "Practice"
  }
}

# Internet Gateway for the Public Subnet
resource "aws_internet_gateway" "k3s_igw" {
  vpc_id = aws_vpc.k3s_vpc.id

  tags = {
    Name    = "k3s_igw"
    Env     = "Practice"
  }
}

# Elastic IP for the NAT Gateway
resource "aws_eip" "k3s_eip" {

  tags = {
    Name    = "k3s_eip"
    Env     = "Practice"
  }
}

# NAT Gateway for the Private Subnet
resource "aws_nat_gateway" "k3s_nat_gateway" {
  allocation_id = aws_eip.k3s_eip.id
  subnet_id     = aws_subnet.k3s_public_subnet.id

  tags = {
    Name    = "k3s_nat_gateway"
    Env     = "Practice"
  }
}

# Public Subnet
resource "aws_subnet" "k3s_public_subnet" {
  vpc_id                  = aws_vpc.k3s_vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = local.public_az
  map_public_ip_on_launch = true

  tags = {
    Name    = "k3s_public_subnet"
    Env     = "Practice"
  }
}

# Private Subnet
resource "aws_subnet" "k3s_private_subnet" {
  vpc_id                  = aws_vpc.k3s_vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = local.private_az

  tags = {
    Name    = "k3s_private_subnet"
    Env     = "Practice"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "k3s_public_rt" {
  vpc_id = aws_vpc.k3s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.k3s_igw.id
  }

  tags = {
    Name    = "k3s_public_rt"
    Env     = "Practice"
  }
}

# Route Table for Private Subnet
resource "aws_route_table" "k3s_private_rt" {
  vpc_id = aws_vpc.k3s_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.k3s_nat_gateway.id
  }

  tags = {
    Name    = "k3s_private_rt"
    Env     = "Practice"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "k3s_public_subnet_association" {
  subnet_id      = aws_subnet.k3s_public_subnet.id
  route_table_id = aws_route_table.k3s_public_rt.id
}


# Associate Route Table with Private Subnet
resource "aws_route_table_association" "k3s_private_subnet_association" {
  subnet_id      = aws_subnet.k3s_private_subnet.id
  route_table_id = aws_route_table.k3s_private_rt.id
}

# Network ACL for k3s resources
resource "aws_network_acl" "k3s_nacl" {
  vpc_id = aws_vpc.k3s_vpc.id

  tags = {
    Name    = "k3s_nacl"
    Env     = "Practice"
  }   
  
}

# Ingress rule allowing all traffic from any IP and any port
resource "aws_network_acl_rule" "k3s_ingress" {
  network_acl_id = aws_network_acl.k3s_nacl.id
  rule_number    = 100
  egress         = false                   # Ingress rule
  protocol       = -1                      # All protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"             # Allow from anywhere
  from_port      = 0                       # Any port
  to_port        = 0
}

# Egress rule allowing all traffic to any IP and any port
resource "aws_network_acl_rule" "k3s_egress" {
  network_acl_id = aws_network_acl.k3s_nacl.id
  rule_number    = 100
  egress         = true                    # Egress rule
  protocol       = -1                      # All protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"             # Allow to anywhere
  from_port      = 0                       # Any port
  to_port        = 0
}

# Associate public subnet with the NACL
resource "aws_network_acl_association" "k3s_public_subnet_association" {
  subnet_id      = aws_subnet.k3s_public_subnet.id
  network_acl_id = aws_network_acl.k3s_nacl.id
}

# Associate private subnet with the NACL
resource "aws_network_acl_association" "k3s_private_subnet_association" {
  subnet_id      = aws_subnet.k3s_private_subnet.id
  network_acl_id = aws_network_acl.k3s_nacl.id
}


# Security Group for Bastion & Proxy
resource "aws_security_group" "k3s_proxy_sg" {
  vpc_id = aws_vpc.k3s_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from the internet
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from the internet
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from the internet
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from the internet
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH access from the internet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name    = "k3s_proxy_sg"
    Env     = "Practice"
  }
}

# Security Group for k3s Cluster
resource "aws_security_group" "k3s_cluster_sg" {
  vpc_id = aws_vpc.k3s_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [aws_security_group.k3s_proxy_sg.id] # Allow all inbound traffic from the proxy
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name      = "k3s_cluster_sg"
    Env       = "practice"
    
  }
}

resource "aws_key_pair" "k3s_key" {
  key_name   = "k3s_key"
  public_key = file("~/.ssh/id_rsa.pub")
    
  tags     = {
    Name     = "macbook-key"
    Env      = "practice"
  }
}

# EC2 Instance for master in Private Subnet
resource "aws_instance" "k3s_master" {
  count                       = 1
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.k3s_private_subnet.id
  private_ip                  = "10.10.2.10"
  security_groups             = [aws_security_group.k3s_cluster_sg.id]
  associate_public_ip_address = false
  key_name                    = "k3s_key"
  root_block_device {
    volume_size = 12
    volume_type = "gp2"
  }

  tags = {
    Name      = "k3s_master"
    Cluster   = "controlplane"
    Env       = "practice"
  }
}

# EC2 Instances for Node in Private Subnet
resource "aws_instance" "k3s_node" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.k3s_private_subnet.id
  private_ip                  = "10.10.2.20${count.index + 1}"
  security_groups             = [aws_security_group.k3s_cluster_sg.id]
  associate_public_ip_address = false
  key_name                    = "k3s_key"
  root_block_device {
    volume_size = 12
    volume_type = "gp2"
  }

  tags = {
    Name    = "k3s_node-${count.index + 1}"
    Cluster = "nodes"
    Env     = "Practice"
  }
}

# Create an archive of the Ansible files
data "archive_file" "ansible_files" {
  type        = "tar.gz"
  source_dir  = "./ansible"
  output_path = "./k3s_files.tar.gz"
}

# EC2 Instances for k3s proxy in Public Subnet
resource "aws_instance" "k3s_proxy" {
  count                       = 1
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.k3s_public_subnet.id
  private_ip                  = "10.10.1.10"
  security_groups             = [aws_security_group.k3s_proxy_sg.id]
  associate_public_ip_address = true
  key_name                    = "k3s_key"
  root_block_device {
    volume_size = 12
    volume_type = "gp2"
  }

  tags = {
    Name    = "k3s_proxy"
    Env     = "Practice"
  }

# Provisioner to copy the private key
  provisioner "file" {
    source        = "~/.ssh/id_rsa"
    destination   = "/home/ubuntu/k3s_key.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }


# Provisioner to copy the files
  provisioner "file" {
    source        = data.archive_file.ansible_files.output_path
    destination   = "/home/ubuntu/k3s_files.tar.gz"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }


# Provisioner to set permissions for the copied key
  provisioner "remote-exec" {
      inline = [
      "tar -xzf /home/ubuntu/k3s_files.tar.gz -C /home/ubuntu/",
      "rm /home/ubuntu/k3s_files.tar.gz ",
      "chmod 400 /home/ubuntu/k3s_key.pem",
      "chmod +x /home/ubuntu/install.sh",
      "bash /home/ubuntu/install.sh",
      "ansible-playbook playbooks/main.yml"
      ]

    connection {
      type          = "ssh"
      user          = "ubuntu"
      private_key   = file("~/.ssh/id_rsa")
      host          = self.public_ip
    }
  }
}


