variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
  default     = "ap-south-2"
}

variable "aws_access_key" {
  description = "AWS Access Key"
  type        = string
  sensitive   = true
}


variable "aws_secret_key" {
  description = "AWS Secret Key"
  type        = string
  sensitive   = true
}

variable "ami_id" {
  description = ""
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instances"
  type        = string
  default     = "t3.micro"
}
