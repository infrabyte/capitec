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
terraform/
    argocd.tf
    repository.tf
    variables.tf
    outputs.tf

argocd/
    applications/
        capitec.yaml
        ingress-nginx.yaml
        monitoring.yaml
        postgresql.yaml

    bootstrap/
        applications.yaml

    values/
        argocd-values.yaml
        monitoring-values.yaml

    argocd-ingress.yaml
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

Any Git commit automatically synchronizes to Kubernetes.

---

## 3. Container Images

Application images are stored in

```
GitHub Container Registry
```

Example

```
ghcr.io/infrabyte/capitec:latest
```

---

## 4. Ingress

NGINX Ingress Controller exposes

```
argocd.jumphost
grafana.jumphost
prometheus.jumphost
```

through a single AWS Load Balancer.

---

# GitOps Workflow

Developer

↓

Push code

↓

GitHub

↓

Container Image built

↓

GHCR

↓

Update Helm values

↓

Git Commit

↓

ArgoCD detects change

↓

Deploy automatically

↓

Kubernetes

---

# Security Review

During implementation several security issues were identified and corrected.

---

## 1. Git Repository Authentication

### Issue

ArgoCD could not authenticate to GitHub.

Initial errors included

```
SSH_AUTH_SOCK not specified
```

followed by

```
Permission denied (publickey)
```

Investigation showed

- incorrect private key
- Windows CRLF line endings inside Terraform variables
- invalid repository URL

### Resolution

- Generated dedicated deployment key
- Added Deploy Key to GitHub
- Stored private key as Kubernetes Secret
- Switched Terraform to load the key directly from file
- Removed Windows CRLF characters

---

## 2. Private Key Storage

### Initial implementation

Private key embedded directly inside

```
terraform.tfvars
```

Problems

- difficult to manage
- Windows line endings corrupted the key
- sensitive information stored directly in configuration

### Improved implementation

Terraform now loads

```
~/.ssh/capitec_argocd
```

using

```
file(...)
```

Advantages

- easier rotation
- no formatting issues
- avoids storing private keys inside Terraform source

---

## 3. Principle of Least Privilege

Repository access is restricted using

GitHub Deploy Keys

instead of Personal Access Tokens.

Deploy Keys provide

- repository-specific access
- read-only permissions
- no user credentials stored

---

## 4. GitOps

Infrastructure changes occur only through Git.

Benefits

- audit trail
- rollback capability
- version control
- reproducible deployments

---

## 5. Image Registry

Private container images are stored inside GitHub Container Registry.

Benefits

- authenticated image pulls
- centralized image management
- versioned deployments

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

- automatic drift correction
- orphaned resources removed
- desired state continuously enforced

---

## 7. HTTPS Ingress

Applications are exposed through a single ingress controller.

Advantages

- central entry point
- TLS support
- easier certificate management
- simplified routing

---

# Challenges Encountered

Several issues were encountered during deployment.

## CRD Timing

Terraform attempted to create the Root Application before ArgoCD CRDs existed.

Resolved by waiting for ArgoCD installation before applying the Root Application.

---

## Repository Authentication

Incorrect SSH key and Windows CRLF formatting caused repeated authentication failures.

Resolved through

- dedicated Deploy Key
- Linux formatted key file
- repository secret recreation

---

## ArgoCD Sync

Root Application remained

```
Unknown
```

until repository authentication succeeded.

---

## Ingress

NGINX backend protocol initially mismatched ArgoCD server configuration resulting in HTTP 502 responses.

The ingress configuration was updated to match the server configuration.

---

# Future Improvements

If this platform were extended further, the following enhancements would be recommended.

## Security

- External Secrets Operator
- AWS Secrets Manager
- Sealed Secrets
- SOPS encryption

---

## Supply Chain Security

- Cosign image signing
- SBOM generation
- Trivy image scanning
- Admission Controller policy enforcement

---

## Kubernetes Security

- Kyverno
- OPA Gatekeeper
- Pod Security Standards
- Network Policies

---

## CI/CD

- GitHub Actions
- Automated semantic versioning
- Progressive deployments
- Canary releases

---

## Observability

- Loki
- Tempo
- OpenTelemetry
- Alertmanager integrations

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


Retrieve ArgoCD password with
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

ArgoCD Pass:
RQfr9XaX5op0TzlW
