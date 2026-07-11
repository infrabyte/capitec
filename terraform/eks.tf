data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.37"

  cluster_name                    = "${var.project_name}-eks"
  cluster_version                 = "1.36"
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  enable_cluster_creator_admin_permissions = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]

  vpc_id     = data.aws_vpc.default.id
  subnet_ids = data.aws_subnets.default.ids

  enable_irsa = true

  eks_managed_node_groups = {
    default = {
      instance_types = ["t3.small"]

      desired_size = 2
      min_size     = 2
      max_size     = 2

      disk_size = 30

      capacity_type = "ON_DEMAND"
      ami_type      = "AL2023_x86_64_STANDARD"
    }
  }

  tags = {
    Project     = var.project_name
    Environment = "assessment"
    ManagedBy   = "Terraform"
  }
}