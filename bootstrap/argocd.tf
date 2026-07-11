resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {

  depends_on = [
    kubernetes_namespace.argocd
  ]

  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  # version          = "8.2.7"
  version = var.argocd_chart_version

  namespace        = "argocd"

  create_namespace = false

  timeout = 900
  wait    = true

  values = [
    file("${path.module}/../argocd/values/argocd-values.yaml")
  ]
}