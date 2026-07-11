# GitHub Repository Secret

# variable "github_repository" {
#   default = "git@github.com:infrabyte/capitec.git"
# }

# variable "github_private_key" {
#   sensitive = true
# }

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
    sshPrivateKey = var.github_private_key
  }
}