# VPCssh 
resource "aws_vpc" "lab_vpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "lab_vpc"
    Env     = "Practice"
  }
}

# Internet Gateway 
resource "aws_internet_gateway" "lab_igw" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name    = "lab_igw"
    Env     = "Practice"
  }
}

# Public Subnet
resource "aws_subnet" "lab_public_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = local.public_az
  map_public_ip_on_launch = true

  tags = {
    Name    = "lab_public_subnet"
    Env     = "Practice"
  }
}

# Private Subnet
resource "aws_subnet" "lab_private_subnet" {
  vpc_id                  = aws_vpc.lab_vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = local.private_az

  tags = {
    Name    = "lab_private_subnet"
    Env     = "Practice"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "lab_public_rt" {
  vpc_id = aws_vpc.lab_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab_igw.id
  }

  tags = {
    Name    = "lab_public_rt"
    Env     = "Practice"
  }
}


# Associate Route Table with Public Subnet
resource "aws_route_table_association" "lab_public_subnet_association" {
  subnet_id      = aws_subnet.lab_public_subnet.id
  route_table_id = aws_route_table.lab_public_rt.id
}

# Network ACL for lab resources
resource "aws_network_acl" "lab_nacl" {
  vpc_id = aws_vpc.lab_vpc.id

  tags = {
    Name    = "lab_nacl"
    Env     = "Practice"
  }   
  
}

# Ingress rule allowing all traffic from any IP and any port
resource "aws_network_acl_rule" "lab_ingress" {
  network_acl_id = aws_network_acl.lab_nacl.id
  rule_number    = 100
  egress         = false                   # Ingress rule
  protocol       = -1                      # All protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"             # Allow from anywhere
  from_port      = 0                       # Any port
  to_port        = 0
}

# Egress rule allowing all traffic to any IP and any port
resource "aws_network_acl_rule" "lab_egress" {
  network_acl_id = aws_network_acl.lab_nacl.id
  rule_number    = 100
  egress         = true                    # Egress rule
  protocol       = -1                      # All protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"             # Allow to anywhere
  from_port      = 0                       # Any port
  to_port        = 0
}

# Associate public subnet with the NACL
resource "aws_network_acl_association" "lab_public_subnet_association" {
  subnet_id      = aws_subnet.lab_public_subnet.id
  network_acl_id = aws_network_acl.lab_nacl.id
}

# Associate private subnet with the NACL
resource "aws_network_acl_association" "lab_private_subnet_association" {
  subnet_id      = aws_subnet.lab_private_subnet.id
  network_acl_id = aws_network_acl.lab_nacl.id
}


# Security Group for Bastion & Proxy
resource "aws_security_group" "k3s_sg" {
  name = "k3s_sg"
  vpc_id = aws_vpc.lab_vpc.id

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
    Name    = "lab_proxy_sg"
    Env     = "Practice"
  }
}


resource "aws_key_pair" "lab_key" {
  key_name   = "lab_key"
  public_key = file("~/.ssh/id_rsa.pub")
    
  tags     = {
    Name     = "macbook-key"
    Env      = "practice"
  }
}


# EC2 Instances for Nodes
resource "aws_instance" "k3s_node" {
  count                       = 2
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.lab_public_subnet.id
  private_ip                  = "10.10.1.20${count.index + 1}"
  security_groups             = [aws_security_group.k3s_sg.id]
  associate_public_ip_address = true
  key_name                    = "lab_key"
  root_block_device {
    volume_size = 12
    volume_type = "gp2"
  }

  tags = {
    Name    = "lab_node-${count.index + 1}"
    Cluster = "nodes"
    Env     = "Practice"
  }
}


# EC2 Instances for master
resource "aws_instance" "k3s_master" {
  # count                       = 1
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.lab_public_subnet.id
  private_ip                  = "10.10.1.10"
  security_groups             = [aws_security_group.k3s_sg.id]
  associate_public_ip_address = true
  key_name                    = "lab_key"
  root_block_device {
    volume_size = 12
    volume_type = "gp2"
  }

  tags = {
    Name    = "lab_proxy"
    Env     = "Practice"
  }
  
}

resource "local_file" "ansible_inventory" {
  filename = "inventory.ini"
  content  = <<EOT
# ansible/inventory.ini
[master]
master1 ansible_host=${aws_instance.k3s_master.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_common_args='-o StrictHostKeyChecking=no'

[nodes]
%{ for idx, ip in aws_instance.k3s_node[*].public_ip ~}
node${idx + 1} ansible_host=${ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_ssh_common_args='-o StrictHostKeyChecking=no'
%{ endfor ~}

EOT
}

resource "null_resource" "ansible_run" {
  depends_on = [aws_instance.k3s_master, aws_instance.k3s_node]

  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.ini playbook.yml"
  }
}
