# DevOps Cyber Assessment

A small internal expense-tracking API.

## Stack

- Flask (Python) REST API
- Postgres
- Helm chart for Kubernetes deployment
- Terraform (AWS) for supporting cloud infra
- GitHub Actions for CI/CD

## API

- `GET /health` - liveness check
- `GET /expenses` - list expenses
- `POST /expenses` - create an expense, body: `{"description": "...", "amount": 12.34}`

## Run locally

```bash
docker compose up --build
curl localhost:5000/health
curl localhost:5000/expenses
```

## Deploy to Kubernetes

```bash
helm install devops-cyber-assessment ./helm/devops-cyber-assessment
```

You'll need to point `image.repository`/`image.tag` at an image you've built and pushed, and supply DB connection details appropriate to your cluster.

## Cloud infra

Terraform in `terraform/` provisions supporting AWS resources blah...blah.

```bash
cd terraform
terraform init
terraform plan
```
