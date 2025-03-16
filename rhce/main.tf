# VPC in  
resource "aws_vpc" "rhce_vpc" {
  cidr_block           = "192.168.55/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "rhce_vpc"
    Env = "test"
    Res = "Practice"
  }
}

# Public Subnet
resource "aws_subnet" "rhce_public_subnet" {
  vpc_id                  = aws_vpc.rhce_vpc.id
  cidr_block              = "10.10.1.0/24"
  availability_zone       = local.public_az
  map_public_ip_on_launch = true

  tags = {
    Name = "rhce_public_subnet"
    Env = "test"
  }
}

# Private Subnet
resource "aws_subnet" "rhce_private_subnet" {
  vpc_id                  = aws_vpc.rhce_vpc.id
  cidr_block              = "10.10.2.0/24"
  availability_zone       = local.private_az

  tags = {
    Name = "rhce_private_subnet"
    Env = "test"
  }
}

# Internet Gateway for the Public Subnet
resource "aws_internet_gateway" "rhce_igw" {
  vpc_id = aws_vpc.rhce_vpc.id

  tags = {
    Name = "rhce_igw"
    Env = "test"
  }
}

# Nat Gateway for the Public Subnet
resource "aws_nat_gateway" "rhce_nat" {
  subnet_id = aws_subnet.rhce_private_subnet.id

  tags = {
    Name = "rhce_nat"
    Env = "test"
  }
}


# Nacl for the rhce vpov
# Main Network ACL resource
resource "aws_network_acl" "rhce_nacl" {
  vpc_id = aws_vpc.rhce_vpc.id

  tags = {
    Name = "rhce_nacl"
    Env  = "test"
  }
}

# Ingress rule allowing all traffic from any IP and any port
resource "aws_network_acl_rule" "rhce_ingress" {
  network_acl_id = aws_network_acl.rhce_nacl.id
  rule_number    = 100
  egress         = false                   # Ingress rule
  protocol       = -1                      # All protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"             # Allow from anywhere
  from_port      = 0                       # Any port
  to_port        = 0
}

# Egress rule allowing all traffic to any IP and any port
resource "aws_network_acl_rule" "rhce_egress" {
  network_acl_id = aws_network_acl.rhce_nacl.id
  rule_number    = 100
  egress         = true                    # Egress rule
  protocol       = -1                      # All protocols
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"             # Allow to anywhere
  from_port      = 0                       # Any port
  to_port        = 0
}
# Associate each subnet with the NACL
resource "aws_network_acl_association" "rhce_publicsubnet_association" {
  subnet_id      = aws_subnet.rhce_public_subnet.id        # Replace with your subnet ID
  network_acl_id = aws_network_acl.rhce_nacl.id
}

resource "aws_network_acl_association" "rhce_privatesubnet_association" {
  subnet_id      = aws_subnet.rhce_private_subnet.id       # Replace with your subnet ID
  network_acl_id = aws_network_acl.rhce_nacl.id
}


# Route Table for Public Subnet
resource "aws_route_table" "rhce_public_rt" {
  vpc_id = aws_vpc.rhce_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.rhce_igw.id
  }

  tags = {
    Name = "rhce_public_rt"
    Env = "test"
  }
}

# Route Table for Private Subnet
resource "aws_route_table" "rhce_private_rt" {
  vpc_id = aws_vpc.rhce_vpc.id

  tags = {
    Name = "rhce_private_rt"
    Env = "test"
  }
}

# Associate Route Table with Public Subnet
resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.rhce_public_subnet.id
  route_table_id = aws_route_table.rhce_public_rt.id
}

# Associate Route Table with Private Subnet
resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.rhce_private_subnet.id
  route_table_id = aws_route_table.rhce_private_rt.id
}

# Security Group for Public Subnet (Control Node)
resource "aws_security_group" "rhce_public_sg" {
  vpc_id = aws_vpc.rhce_vpc.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "rhce_public_sg"
  }
}

# Security Group for Private Subnet (Nodes 1-4)
resource "aws_security_group" "rhce_private_sg" {
  vpc_id = aws_vpc.rhce_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    # Allow SSH access from the public subnet
    cidr_blocks = [aws_subnet.rhce_public_subnet.cidr_block]
  }

  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    # Allow SSH access from the public subnet
    cidr_blocks = [aws_subnet.rhce_public_subnet.cidr_block]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    # Allow SSH access from the public subnet
    cidr_blocks = [aws_subnet.rhce_public_subnet.cidr_block]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    # Allow SSH access from the public subnet
    cidr_blocks = [aws_subnet.rhce_public_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "rhce_private_sg"
  }
}

resource "aws_key_pair" "rhce_key" {
  key_name   = "rhce_key"
  public_key = file("~/.ssh/id_rsa.pub")
    tags     = {
    Name     = "macbook-key"
    Env      = "test"
    Res      = "Practice"
  }
}

# EC2 Instance for Control Node in Public Subnet
resource "aws_instance" "control_node" {
  count                       = 1
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.rhce_public_subnet.id
  private_ip                  = "10.10.1.10"
  security_groups             = [aws_security_group.rhce_public_sg.id]
  associate_public_ip_address = true
  key_name                    = "rhce_key"
  root_block_device {
    volume_size = 12  # Size in GB
    volume_type = "gp2"  # Volume type (e.g., gp2, gp3, io1, etc.)
  }

  tags = {
    Name = "control-node"
    Env = "test"
    Res = "Practice"
  }
  
  # Provisioner to copy the private key
  provisioner "file" {
    source      = "~/.ssh/id_rsa"
    destination = "/home/ubuntu/private-key.pem"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }

    provisioner "file" {
    source      = "./ansible"
    destination = "/home/ubuntu/ansible"

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
      "chmod 400 /home/ubuntu/private-key.pem && chmod +x /home/ubuntu/ansible/install.sh && bash /home/ubuntu/ansible/install.sh" #&& cd /home/ubuntu/ansible && ansible-playbook playbooks/main.yml"
      ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("~/.ssh/id_rsa")
      host        = self.public_ip
    }
  }
}

# EC2 Instance for Master Node in Public Subnet
resource "aws_instance" "master_node" {
  count                       = 1
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.rhce_public_subnet.id
  private_ip                  = "10.10.1.15"
  security_groups             = [aws_security_group.rhce_public_sg.id]
  associate_public_ip_address = true
  key_name                    = "rhce_key"
  root_block_device {
    volume_size = 12  # Size in GB
    volume_type = "gp2"  # Volume type (e.g., gp2, gp3, io1, etc.)
  }

  tags = {
    Name = "master-node"
    Env = "test"
    Res = "Practice"
  }
}

# EC2 Instances for Nodes in Private Subnet
resource "aws_instance" "nodes" {
  count                       = 1
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.rhce_private_subnet.id
  private_ip                  = "10.10.2.1${count.index + 1}"
  security_groups             = [aws_security_group.rhce_private_sg.id]
  associate_public_ip_address = false
  key_name                    = "rhce_key"
  root_block_device {
    volume_size = 12  # Size in GB
    volume_type = "gp2"  # Volume type (e.g., gp2, gp3, io1, etc.)
  }

  tags = {
    Name = "node-${count.index + 1}"
    Env = "test"
    Res = "Practice"
  }
}

# EBS Volumes for Nodes 
resource "aws_ebs_volume" "rhce_node_volumes" {
  count              = 1
  size               = 8
  type               = "gp2"
  availability_zone  = aws_instance.nodes[count.index].availability_zone
}

# Attach EBS Volumes to Nodes 1-4
resource "aws_volume_attachment" "ebs_attachment" {
  count       = 1
  device_name = "/dev/sdf" # You can change this if necessary
  instance_id = aws_instance.nodes[count.index].id
  volume_id   = aws_ebs_volume.rhce_node_volumes[count.index].id
}
