output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}

output "subnet_ids" {
  value = data.aws_subnets.default.ids
}

output "cluster_version" {
  value = module.eks.cluster_version
}

output "region" {
  value = var.aws_region
}

output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "artifacts_bucket" {
  value = aws_s3_bucket.artifacts.bucket
}

output "ci_deploy_access_key_id" {
  value     = aws_iam_access_key.ci_deploy.id
  sensitive = true
}

output "ci_deploy_secret_access_key" {
  value     = aws_iam_access_key.ci_deploy.secret
  sensitive = true
}
