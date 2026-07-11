# variable "aws_region" {
#   description = "AWS region to deploy into"
#   type        = string
#   default     = "af-south-1"
# }

# variable "project_name" {
#   description = "Name prefix for resources"
#   type        = string
#   default     = "devops-cyber-assessment"
# }

variable "github_repository" {
  description = "Git repository containing the Argo CD manifests"
  type        = string
  default     = "ssh://git@github.com/infrabyte/capitec.git"
}

variable "github_private_key" {
  description = "SSH private key used by Argo CD to access the Git repository"
  type        = string
  sensitive   = true
}

variable "argocd_namespace" {
  description = "Namespace where Argo CD will be installed"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of the Argo CD Helm chart"
  type        = string
  default     = "8.2.7"
}