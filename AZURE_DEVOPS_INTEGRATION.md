# Integration Guide: syft-trivy-docker-image with Azure DevOps Templates

This Docker image is designed to work seamlessly with the SBOM security templates from the AERprogress by Bavaria project.

## Repository Structure

```
templates/
├── jobs/
│   ├── sbom-generate.yml          ← SBOM generation job template
│   ├── docker-build.yml           ← Docker build job template
│   └── npm-test.yml               ← NPM test job template
├── steps/
│   └── sbom-tool-setup.yml        ← Tool setup step (uses our Docker image)
└── stages/
    └── sbom-security.yml          ← Security scanning stage
```

## What Our Docker Image Provides

- **Syft v1.24.1** - SBOM generation (SPDX 2.3, CycloneDX)
- **Trivy v0.53.0** - Vulnerability scanning
- Pre-configured for Azure DevOps pipelines
- Works with both filesystem and Docker image scanning

## How Templates Use This Image

### 1. Template: `jobs/sbom-generate.yml`

This template:
- Calls our Docker image to run Syft and Trivy
- Generates SBOM in SPDX 2.3 and CycloneDX formats
- Scans for vulnerabilities
- Publishes reports and artifacts
- Optionally notifies via Teams or email

**Key steps:**
```yaml
# Uses syft to generate SBOM
syft dir:$(Build.Repository.LocalPath) -o spdx-json > out/sbom/spdx-2.3.json

# Uses trivy to scan for vulnerabilities
trivy sbom --format json --severity HIGH,CRITICAL out/sbom/spdx-2.3.json
```

### 2. Template: `steps/sbom-tool-setup.yml`

This template:
- Prepares the environment
- Downloads/installs Syft and Trivy binaries
- Alternative to using our Docker image directly
- Supports Azure Artifacts or preinstalled tools

### 3. Template: `stages/sbom-security.yml`

Orchestrates the entire SBOM workflow:
- Generates SBOMs in multiple formats
- Scans for vulnerabilities
- Creates Azure DevOps work items for findings
- Sends notifications (Teams, Email)
- Can fail the build on critical vulnerabilities

## Integration Pattern

```yaml
# In your azure-pipelines.yml
stages:
  - template: stages/sbom-security.yml@templates
    parameters:
      packageName: $(Build.DefinitionName)
      packageVersion: $(Build.BuildNumber)
      supplier: "Organization: Example Corp"
      failOnSeverity: 'HIGH,CRITICAL'
      toolSource: 'preinstalled'  # Uses tools from Docker image
      notifyTeamsWebhook: $(TEAMS_WEBHOOK)
```

## Running Locally

### Build the Docker Image
```bash
./run.sh build
# or
./build.sh
```

### Test the Image
```bash
./run.sh test
```

### Scan a Project
```bash
# Generate SBOM
./run.sh scan /path/to/project ./sbom-output

# Run security scan
./run.sh security /path/to/project
```

### Manual Docker Commands

```bash
# Generate SPDX 2.3 SBOM
docker run --rm \
  -v /path/to/project:/project \
  -v $(pwd)/out:/out \
  syft-trivy-sbom:latest \
  syft /project -o spdx-json > out/sbom.json

# Scan for vulnerabilities
docker run --rm \
  -v /path/to/project:/project \
  syft-trivy-sbom:latest \
  trivy fs /project --format json

# Scan a Docker image
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  syft-trivy-sbom:latest \
  syft nginx:latest -o json
```

## Azure DevOps Pipeline Example

### Simple Pipeline

```yaml
trigger:
  - main

pool:
  vmImage: 'ubuntu-latest'

stages:
  - stage: SBOM
    displayName: 'Generate SBOM'
    jobs:
      - template: stages/sbom-security.yml@templates
        parameters:
          packageName: $(Build.DefinitionName)
          packageVersion: $(Build.BuildNumber)
          supplier: "Organization: Example Corp"
          workdir: $(Build.SourcesDirectory)
          failOnSeverity: 'HIGH,CRITICAL'
          breakOnFindings: true
          toolSource: 'preinstalled'
          poolName: 'default'
          containerImage: 'syft-trivy-sbom:latest'
          notifyTeamsWebhook: $(TEAMS_WEBHOOK_URL)
```

### Advanced Pipeline with Multiple Stages

```yaml
trigger:
  - main
  - develop

variables:
  DOCKER_IMAGE: 'syft-trivy-sbom:latest'

stages:
  - stage: Build
    displayName: 'Build & Test'
    jobs:
      - job: BuildJob
        steps:
          - task: Docker@2
            inputs:
              command: 'build'
              tags: $(DOCKER_IMAGE)

  - stage: SBOM
    displayName: 'SBOM Generation & Security'
    dependsOn: Build
    jobs:
      - template: stages/sbom-security.yml@templates
        parameters:
          packageName: my-app
          packageVersion: $(Build.BuildNumber)
          supplier: "Organization: Example Corp"
          failOnSeverity: 'HIGH,CRITICAL'
          breakOnFindings: true
          notifyTeamsWebhook: $(TEAMS_WEBHOOK)
          notifyAdoOrgUrl: https://dev.azure.com/yourorg
          notifyAdoProject: YourProject

  - stage: Deploy
    displayName: 'Deploy'
    dependsOn: SBOM
    condition: succeeded()
    jobs:
      - deployment: Production
        environment: Production
        strategy:
          runOnce:
            deploy:
              steps:
                - script: echo "Deploying..."
```

## Configuration Reference

### Common Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `packageName` | $(Build.DefinitionName) | SBOM package name |
| `packageVersion` | $(Build.BuildNumber) | SBOM package version |
| `supplier` | '' | Organization/Supplier info |
| `workdir` | $(Build.SourcesDirectory) | Directory to scan |
| `failOnSeverity` | HIGH,CRITICAL | Vulnerability severity levels |
| `breakOnFindings` | true | Fail build if vulnerabilities found |
| `toolSource` | azureArtifacts | 'azureArtifacts' or 'preinstalled' |

### Notification Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `notifyTeamsWebhook` | '' | Teams webhook URL |
| `notifyEmailEnabled` | false | Enable email notifications |
| `notifyAdoOrgUrl` | '' | Azure DevOps org URL |
| `notifyAdoProject` | '' | Azure DevOps project |

## Troubleshooting

### Image Not Found
```bash
docker pull syft-trivy-sbom:latest
# or rebuild
./run.sh build
```

### Permission Denied
```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Docker Socket Issues in Azure DevOps
```yaml
# In your pipeline
container: syft-trivy-sbom:latest
# Docker socket should be available in most Azure DevOps agents
```

### Trivy Database Updates
Trivy downloads vulnerability database on first run (~80MB). This happens automatically.

## Resources

- **Syft:** https://github.com/anchore/syft
- **Trivy:** https://github.com/aquasecurity/trivy
- **SPDX 2.3:** https://spdx.dev
- **CycloneDX:** https://cyclonedx.org
- **TR-03183-2:** German security standard

## Support

For issues or questions:
1. Check the logs in Azure DevOps pipeline
2. Review published artifacts (sbom, sbom-scan)
3. Verify tool versions: `./run.sh version`
4. Test locally: `./run.sh test`
