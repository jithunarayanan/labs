output "control_node_private_ip" {
  value       = aws_instance.control_node[0].private_ip
  description = "Private IP of the control node"
}

output "control_node_public_ip" {
  value       = aws_instance.control_node[0].public_ip
  description = "Public IP of the control node"
}

output "master_node_private_ip" {
  value       = aws_instance.master_node[0].private_ip
  description = "Private IP of the master node"
}

output "master_nodenode_public_ip" {
  value       = aws_instance.master_node[0].public_ip
  description = "Public IP of the master node"
}

output "node_private_ips" {
  value       = [for instance in aws_instance.nodes : instance.private_ip]
  description = "Private IPs of nodes 1-4"
}

