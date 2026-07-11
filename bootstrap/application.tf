resource "null_resource" "root_application" {

  depends_on = [
    helm_release.argocd,
    kubernetes_secret.argocd_repository
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]

    command = <<EOT
set -e

echo "Waiting for ArgoCD CRDs..."
kubectl wait --for=condition=Established \
  crd/applications.argoproj.io \
  --timeout=300s

echo "Applying Root Application..."
kubectl apply -f ${path.module}/../argocd/applications.yaml
EOT
  }
}
