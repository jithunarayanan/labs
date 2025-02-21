output "k3s_proxy_public_ip" {
  value       = [for instance in aws_instance.k3s_proxy : instance.public_ip]
  description = "Public IP of the workstation"
} 
output "k3s_nodes_private_ip" {
  value       = [for instance in aws_instance.k3s_node : instance.private_ip]
  description = "Private IP of the worker nodes"
} 
output "k3s_master_private_ip" {
  value       = [for instance in aws_instance.k3s_master : instance.private_ip]
  description = "Private IP of the master"
} 
