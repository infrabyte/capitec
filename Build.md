# Docker Image Build Pipeline

## Overview

The project uses GitHub Actions to automatically build and publish the application's Docker image whenever the `Dockerfile` is modified and committed to the `main` branch.

The workflow is located at:

```text
.github/workflows/ci.yml
```

## Workflow Trigger

The pipeline is configured to execute only when changes are pushed to the `main` branch that include the `Dockerfile` or any files related to the build of the image.

```yaml
on:
  push:
    branches:
      - main
    paths:
      - Dockerfile
      - requirements.txt
      - app/**
      - src/**
```

This minimizes unnecessary builds by ensuring that a new container image is only created when the Docker image definition changes.

## Build Process

The GitHub Actions workflow performs the following steps:

1. Checks out the latest source code from the repository.
2. Authenticates to GitHub Container Registry (GHCR) using the automatically generated `GITHUB_TOKEN`.
3. Builds the Docker image using the project's `Dockerfile`.
4. Tags the image as:

```
ghcr.io/infrabyte/capitec:latest
```

5. Pushes the image to GitHub Container Registry.

## Authentication

The workflow uses the built-in `GITHUB_TOKEN` provided by GitHub Actions.

Required permissions:

```yaml
permissions:
  contents: read
  packages: write
```

No Personal Access Token (PAT) is required when publishing to the same GitHub repository's container registry.

## Container Registry

Container images are published to GitHub Container Registry (GHCR):

```
ghcr.io/infrabyte/capitec
```

Using GHCR keeps the source code repository and container images within the same GitHub ecosystem, simplifying authentication and repository management.

## Integration with Kubernetes

The Kubernetes deployment references the image stored in GitHub Container Registry:

```yaml
image: ghcr.io/infrabyte/capitec:latest
```

When a new image is published, Kubernetes can pull the updated image during the next deployment or pod restart. In a GitOps workflow managed by Argo CD, the deployment manifests remain under version control while the container image is retrieved directly from GHCR.

## Benefits

* Fully automated container image creation.
* Version-controlled build pipeline.
* Secure authentication using GitHub Actions.
* Centralized storage of source code and container images.
* Eliminates the need for an external container registry such as Amazon ECR.
