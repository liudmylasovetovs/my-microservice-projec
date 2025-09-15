variable "region" {
  description = "AWS region for deployment"
  default     = "us-west-2"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "node_subnet_ids" {
  description = "List of subnet IDs for the EKS node group"
  type        = list(string)
}

variable "node_group_name" {
  description = "Name of the node group"
  default     = "node-group-liudmyla"
}

variable "instance_type" {
  description = "EC2 instance type for the worker nodes"
  default     = "t3.micro"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  default     = 3
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  default     = 1
}

