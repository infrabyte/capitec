# GitHub Repository Secret
resource "kubernetes_secret" "argocd_repository" {
  depends_on = [
    helm_release.argocd
  ]

  metadata {
    name      = "capitec-repository"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    type          = "git"
    url           = var.github_repository
    sshPrivateKey = trimspace(file(var.github_private_key_file))
  }
}