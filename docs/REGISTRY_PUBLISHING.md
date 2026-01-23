# Docker Registry Publishing Guide

This guide covers publishing the `syft-trivy-sbom` Docker image to various registries.

## Prerequisites

- Docker installed and running
- Docker image built: `syft-trivy-sbom:latest`
- Credentials for target registry
- Internet access to registry

## Publishing Options

### 1. Docker Hub (Recommended for Public Images)

**Best for:** Public distribution, team sharing

**Prerequisites:**
- Docker Hub account (free at https://hub.docker.com)
- Username and password or access token

**Steps:**

```bash
# Option A: Interactive login
./publish.sh dockerhub --username YOUR_DOCKER_HUB_USERNAME

# Option B: Non-interactive (CI/CD)
echo "$DOCKER_HUB_TOKEN" | docker login -u YOUR_USERNAME --password-stdin
docker tag syft-trivy-sbom:latest YOUR_USERNAME/syft-trivy-sbom:latest
docker push YOUR_USERNAME/syft-trivy-sbom:latest
```

**Usage after publishing:**
```bash
docker pull YOUR_USERNAME/syft-trivy-sbom:latest
docker run -v $(pwd)/project:/project YOUR_USERNAME/syft-trivy-sbom:latest syft /project
```

**Example:**
```bash
./publish.sh dockerhub --username myusername
```

---

### 2. Azure Container Registry (ACR)

**Best for:** Azure DevOps integration, private team registry

**Prerequisites:**
- Azure subscription
- Container Registry created (e.g., `myregistry.azurecr.io`)
- Service principal or user credentials
- Access token or password

**Create Registry (if needed):**
```bash
az group create --name myresourcegroup --location eastus
az acr create --resource-group myresourcegroup --name myregistry --sku Basic
az acr login --name myregistry
```

**Get Access Token:**
```bash
# Option 1: Admin credentials
az acr credential show --name myregistry

# Option 2: Service Principal token
az acr login --name myregistry --username $SERVICE_PRINCIPAL_ID --password $SERVICE_PRINCIPAL_PASSWORD
```

**Publishing:**
```bash
# Using script
./publish.sh acr \
  --registry myregistry.azurecr.io \
  --username $SERVICE_PRINCIPAL_ID \
  --token $SERVICE_PRINCIPAL_PASSWORD

# Manual steps
docker tag syft-trivy-sbom:latest myregistry.azurecr.io/syft-trivy-sbom:latest
docker push myregistry.azurecr.io/syft-trivy-sbom:latest
```

**Usage after publishing:**
```bash
az acr login --name myregistry
docker pull myregistry.azurecr.io/syft-trivy-sbom:latest
```

**Azure DevOps Pipeline Integration:**
```yaml
- task: Docker@2
  inputs:
    command: 'pull'
    repository: '$(ACR_REGISTRY).azurecr.io/syft-trivy-sbom'
    tags: 'latest'
```

---

### 3. GitHub Container Registry (GHCR)

**Best for:** GitHub-hosted projects, private organization registry

**Prerequisites:**
- GitHub account with package permissions
- Personal Access Token (PAT) with `write:packages` scope

**Create PAT:**
1. Go to https://github.com/settings/tokens
2. Create new token with `write:packages` scope
3. Copy token (you won't see it again)

**Publishing:**
```bash
./publish.sh ghcr \
  --username YOUR_GITHUB_USERNAME \
  --token YOUR_PAT_TOKEN

# Manual steps
echo YOUR_PAT_TOKEN | docker login ghcr.io -u YOUR_GITHUB_USERNAME --password-stdin
docker tag syft-trivy-sbom:latest ghcr.io/YOUR_GITHUB_USERNAME/syft-trivy-sbom:latest
docker push ghcr.io/YOUR_GITHUB_USERNAME/syft-trivy-sbom:latest
```

**Usage after publishing:**
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u YOUR_USERNAME --password-stdin
docker pull ghcr.io/YOUR_GITHUB_USERNAME/syft-trivy-sbom:latest
```

---

## Recommended Setup for Your Project

Given your Azure DevOps environment, we recommend **Azure Container Registry (ACR)**:

### Step 1: Create ACR in Azure

```bash
# Set variables
RESOURCE_GROUP="aer-sbom-rg"
REGISTRY_NAME="aersbom"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create registry
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $REGISTRY_NAME \
  --sku Basic
```

### Step 2: Set Up Azure DevOps Integration

**Add ACR as Service Connection:**
1. In Azure DevOps project → Project Settings → Service Connections
2. Click "New service connection" → Docker Registry
3. Select "Azure Container Registry"
4. Choose your subscription and registry
5. Name it: `aer-sbom-registry`

### Step 3: Publish Image

```bash
# Authenticate to ACR
az acr login --name aersbom

# Publish using script
./publish.sh acr \
  --registry aersbom.azurecr.io \
  --username <service-principal-id> \
  --token <service-principal-password>
```

### Step 4: Use in Azure DevOps Pipeline

```yaml
trigger:
  - main

resources:
  repositories:
    - repository: self

variables:
  ACR_REGISTRY: 'aersbom.azurecr.io'
  IMAGE_NAME: 'syft-trivy-sbom'

stages:
- stage: ScanWithSBOM
  jobs:
  - job: GenerateSBOM
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    - task: Docker@2
      inputs:
        command: 'pull'
        repository: '$(ACR_REGISTRY)/$(IMAGE_NAME)'
        tags: 'latest'
    
    - script: |
        docker run \
          -v $(System.DefaultWorkingDirectory):/project \
          -v $(Build.ArtifactStagingDirectory):/sbom-output \
          $(ACR_REGISTRY)/$(IMAGE_NAME):latest \
          syft /project -o spdx-json > $(Build.ArtifactStagingDirectory)/sbom.spdx.json
      displayName: 'Generate SBOM'
```

---

## Verification After Publishing

### Check Image Availability

```bash
# Docker Hub
docker pull YOUR_USERNAME/syft-trivy-sbom:latest
docker run YOUR_USERNAME/syft-trivy-sbom:latest syft --version

# ACR
az acr repository show -n aersbom --repository syft-trivy-sbom
docker pull aersbom.azurecr.io/syft-trivy-sbom:latest

# GHCR
docker pull ghcr.io/YOUR_USERNAME/syft-trivy-sbom:latest
```

### Verify Image Integrity

```bash
# Check image info
docker inspect YOUR_REGISTRY/syft-trivy-sbom:latest | jq '.[] | {ID, Digest, Created}'

# Test image functionality
docker run YOUR_REGISTRY/syft-trivy-sbom:latest syft --version
docker run YOUR_REGISTRY/syft-trivy-sbom:latest trivy version
```

---

## CI/CD Integration for Auto-Publishing

Create an Azure DevOps pipeline to automatically publish on commits:

```yaml
# File: azure-pipelines-publish.yml

trigger:
  branches:
    include:
    - main
  paths:
    include:
    - Dockerfile
    - publish.sh

pool:
  vmImage: 'ubuntu-latest'

variables:
  ACR_REGISTRY: 'aersbom.azurecr.io'
  IMAGE_NAME: 'syft-trivy-sbom'
  IMAGE_TAG: '$(Build.BuildId)'

steps:
- task: Docker@2
  displayName: 'Build Docker Image'
  inputs:
    command: 'build'
    Dockerfile: 'Dockerfile'
    tags: |
      $(IMAGE_TAG)
      latest

- task: Docker@2
  displayName: 'Login to ACR'
  inputs:
    command: 'login'
    containerRegistry: 'aer-sbom-registry'

- task: Docker@2
  displayName: 'Tag Image'
  inputs:
    command: 'tag'
    sourceRepository: '$(IMAGE_NAME)'
    sourceTag: '$(IMAGE_TAG)'
    targetRepository: '$(ACR_REGISTRY)/$(IMAGE_NAME)'
    targetTag: '$(IMAGE_TAG)'

- task: Docker@2
  displayName: 'Push to ACR'
  inputs:
    command: 'push'
    repository: '$(ACR_REGISTRY)/$(IMAGE_NAME)'
    tags: |
      $(IMAGE_TAG)
      latest
```

---

## Troubleshooting

### Authentication Failed
```bash
# Verify credentials
docker login [registry]

# Check config
cat ~/.docker/config.json | jq .

# Logout and retry
docker logout [registry]
docker login [registry]
```

### Image Not Found
```bash
# Verify image exists locally
docker images | grep syft-trivy-sbom

# Rebuild if necessary
./run.sh build

# Check remote
curl https://registry.hub.docker.com/v2/repositories/YOUR_USERNAME/syft-trivy-sbom/
```

### Push Timeout
```bash
# Increase Docker daemon timeout
docker --config ~/.docker push [image] --default-registry-credentials

# Try with verbose output
docker push [image] --verbose
```

---

## Next Steps

1. **Choose your registry** (recommended: Azure Container Registry)
2. **Gather credentials** for your chosen registry
3. **Run publish script** with your credentials
4. **Verify publication** by pulling the image
5. **Update documentation** with published image URL
6. **Set up CI/CD** for automatic publishing on commits

Questions? See `README.md` or `AZURE_DEVOPS_INTEGRATION.md`
