variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "af-south-1"
}

variable "project_name" {
  description = "Name prefix for resources"
  type        = string
  default     = "devops-cyber-assessment"
}
