# Capitec DevOps Technical Assessment

## Overview

This repository contains a complete GitOps-driven Kubernetes platform built as part of the Capitec DevOps / Platform Engineering assessment.

The objective was to demonstrate modern cloud-native engineering practices including:

- Infrastructure as Code using Terraform
- Kubernetes running on AWS
- GitOps using ArgoCD
- Helm-based application deployments
- Secure secret management
- Container image management using GitHub Container Registry (GHCR)
- Automated application reconciliation
- Monitoring using Prometheus and Grafana
- Ingress management using NGINX Ingress Controller

---

# High Level Architecture

```
                        GitHub
                           │
        ┌──────────────────┴─────────────────┐
        │                                    │
 Source Code                         GitOps Repository
        │                                    │
        └──────────────┬─────────────────────┘
                       │
                    ArgoCD
                       │
                Watches Git Repository
                       │
        ┌──────────────┴───────────────┐
        │                              │
    Helm Charts                  Kubernetes Manifests
        │                              │
        └──────────────┬───────────────┘
                       │
                Kubernetes Cluster
                       │
     ┌─────────────────┼─────────────────┐
     │                 │                 │
 PostgreSQL      Monitoring        Capitec App
                     │
            Prometheus + Grafana

                       │
               NGINX Ingress Controller
                       │
                 AWS Load Balancer
                       │
                  HTTPS Endpoints
```

---

# Technology Stack

| Component         | Technology       |
|-------------------|------------------|
| Cloud             | AWS              |
| Infrastructure    | Terraform        |
| Kubernetes        | EKS              |
| GitOps            | ArgoCD           |
| Package Manager   | Helm             |
| Ingress           | ingress-nginx    |
| Registry          | GitHub Container |
| Monitoring        | Prometheus       |
| Dashboards        | Grafana          |
| Database          | PostgreSQL       |
| Container Runtime | Docker           |

---

# Repository Structure

```
.
├── app
│   ├── main.py
│   ├── requirements.txt
│   └── venv
├── argocd
│   ├── applications.yaml
│   ├── argocd-ingress.yaml
│   ├── capitec-ingress.yaml
│   ├── capitec.yaml
│   ├── ingress-nginx.yaml
│   ├── kustomization.yaml
│   ├── monitoring.yaml
│   ├── postgresql.yaml
│   └── values
├── bootstrap
│   ├── application.tf
│   ├── argocd.tf
│   ├── outputs.tf
│   ├── providers.tf
│   ├── repository.tf
│   ├── repository.yaml.bak
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── terraform.tfvars
│   ├── variables.tf
│   └── versions.tf
├── Build.md
├── db
│   └── init.sql
├── docker-compose.yml
├── Dockerfile
├── helm
│   ├── devops-cyber-assessment
│   └── postgresql
├── README.md
├── REQUEST.md
├── terraform
│   ├── ebs-csi.tf
│   ├── eks.tf
│   ├── main.tf
│   ├── main.tf.bad
│   ├── outputs.tf
│   ├── terraform.tfstate
│   ├── terraform.tfstate.backup
│   ├── tfplan
│   ├── variables.tf
│   └── versions.tf
```

---

# Deployment Flow

## 1. Terraform

Terraform creates

- Kubernetes namespace
- ArgoCD
- Repository Secret
- Root Application

Terraform is only responsible for bootstrapping.

After this point Terraform is no longer responsible for applications.

---

## 2. ArgoCD

The Root Application points to

```
argocd/
```

which contains

- ingress-nginx
- PostgreSQL
- Monitoring
- Capitec Application

Any Git commit automatically synchronizes to Kubernetes (Unless a sync window is in place).

---

## 3. Container Images

Application images are stored in

```
GitHub Container Registry: ghcr.io/infrabyte/capitec:latest
```

---

## 4. Ingress

NGINX Ingress Controller exposes

```
argocd.jumphost
grafana.jumphost (Scaled to preserve resources)
prometheus.jumphost (Scaled to preserve resources)
```

through a single AWS Load Balancer.

---

# GitOps Workflow
```
Developer -> Push code -> GitHub -> Container Image built -> GHCR -> Update Helm values -> Git Commit -> ArgoCD detects change -> Deploy automatically (Unless a sync window is in place) -> Kubernetes
```
---

# Security Review

During implementation several security issues were identified and corrected.

---

## 1. ECR

### Issue
```
Mutable tags.
```
### Risk
```
Images can be overwritten
```
### Resolution
```
Make tags immutable
```
---

## 2. S3

### Issue(s)
```
- Public Access Block disabled
- Public bucket policy
- No encryption
- No versioning
```
### Risk
```
- Bucket can become public
- Anyone on the Internet can read objects
- Data at rest not encrypted
- Accidental deletion/data loss
```
### Resolution
```
- Enable all public access blocks
- Remove public policy
- Enable SSE (AES256 or KMS)
- Enable versioning
```

---

## 3. IAM

### Issue(s)
```
- Long-lived IAM user
- Access key
- Action="*"
- Resource="*"
```
### Risk
```
- Static credentials
- Permanent credentials
- Full administrator access
- Access to everything
```
### Resolution
```
- Prefer IAM Roles/OIDC
- Avoid where possible
- Principle of Least Privilege
- Scope resources
```

---

## 4. General

Infrastructure changes occur only through Git.

Benefits
```
- audit trail
- rollback capability
- version control
- reproducible deployments
```

---

## 5. Image Registry

Private container images are stored inside GitHub Container Registry.

Benefits
```
- authenticated image pulls
- centralized image management
- versioned deployments
```

---

## 6. ArgoCD Automated Reconciliation

Enabled

```
selfHeal
```
and
```
prune
```

Advantages
```
- automatic drift correction
- orphaned resources removed
- desired state continuously enforced
```
---

## 7. HTTPS Ingress

Applications are exposed through a single ingress controller.

Advantages
```
- central entry point
- TLS support
- easier certificate management
- simplified routing
```
---

# Challenges Encountered

### Issue
```
No tagging
```
### Risk
```
Poor governance
```
### Resolution
```
Add standard tags
```

## CRD Timing

Terraform attempted to create the Root Application before ArgoCD CRDs existed.

Resolved by waiting for ArgoCD installation before applying the Root Application.

---

# Future Improvements

If this platform were extended further, the following enhancements would be recommended.

## Security
```
- External Secrets Operator
- AWS Secrets Manager
- Sealed Secrets
- SOPS encryption
```
---

## Supply Chain Security
```
- Cosign image signing
- SBOM generation
- Trivy image scanning
- Admission Controller policy enforcement
```
---

## Kubernetes Security
```
- Kyverno
- OPA Gatekeeper
- Pod Security Standards
- Network Policies
```
---

## CI/CD
```
- GitHub Actions
- Automated semantic versioning
- Progressive deployments
- Canary releases
```
---

## Observability
```
- Loki
- Tempo
- OpenTelemetry
- Alertmanager integrations
```
---

# Result

The completed platform demonstrates

- Infrastructure as Code
- GitOps deployment model
- Automated reconciliation
- Secure Git repository integration
- Private container registry
- Kubernetes application management
- Monitoring stack
- Cloud-native deployment practices

The resulting environment is fully reproducible, declarative, and managed through Git, following modern Platform Engineering and DevOps best practices.

---

# Admin Notes

Base Packages (Completed on local Ubuntu 24.04 VM)
```
sudo apt update

sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    jq \
    ca-certificates \
    apt-transport-https \
    gnupg \
    lsb-release \
    software-properties-common \
    build-essential \
    openssh-client
```
Install Docker, kubectl, Helm, Configure Git, Create SSH Key, Add SSH Key to GitHub, Create GitHub PAT, To deploy via Terraform

EKS:

Goto ./terraform directory
```
terraform init
terraform validate
terraform plan
terraform apply
```
ArgoCD:

Goto ./bootstrap directory
```
terraform init
terraform validate
terraform plan
terraform apply
```

If you find errors:
eg:
Error: creating Secrets Manager Secret
```
If you destroyed the cluster but not the secret, you'll see something like this.
Check if it exists:
aws secretsmanager list-secrets \
  --region af-south-1

or

aws secretsmanager describe-secret \
  --secret-id devops-cyber-assessment-ci-credentials \
> --region af-south-1

Then remove it and contine:
aws secretsmanager delete-secret \
  --secret-id devops-cyber-assessment-ci-credentials \
>   --force-delete-without-recovery \
  --region af-south-1

Github Code:
https://github.com/infrabyte/capitec

Image:
https://github.com/users/infrabyte/packages/container/package/capitec

Add cluster to kube config:
```
aws eks update-kubeconfig \
  --region af-south-1 \
  --name <cluster-name>
```
Retrieve ArgoCD password with:
```
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```
