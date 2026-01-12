# Local Testing Guide

## Prerequisites

Before running tests locally, ensure Docker is running:

### Option 1: RancherDesktop (Linux)
```bash
# Start RancherDesktop
rancher-desktop

# Or if using systemd
sudo systemctl start docker
```

### Option 2: Docker Desktop
Open the Docker Desktop application from your system menu.

### Option 3: Manual Docker Setup (Linux)
```bash
sudo systemctl start docker
sudo systemctl enable docker  # Auto-start on boot
```

## Running Local Tests

### Basic Test with Default Image (nginx:latest)
```bash
cd /home/r3zafa/syft-trivy-docker-image
./test.sh
```

### Test with Specific Docker Image
```bash
./test.sh alpine:latest
./test.sh python:3.11
./test.sh ubuntu:22.04
```

### Test with Custom Local Image

First, build a local image:
```bash
cd /home/r3zafa/syft-trivy-docker-image/sample-images
docker build -f Dockerfile.example -t my-test-app:latest .

# Then generate SBOM
cd ..
./test.sh my-test-app:latest
```

## Manual Testing Commands

If you want to run individual commands:

### 1. Generate Syft SBOM (JSON)
```bash
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/sbom-output:/sbom-output \
    syft-trivy-sbom:latest \
    syft nginx:latest -o json > sbom-output/sbom.json
```

### 2. Generate Syft SBOM (SPDX)
```bash
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/sbom-output:/sbom-output \
    syft-trivy-sbom:latest \
    syft nginx:latest -o spdx > sbom-output/sbom-spdx.json
```

### 3. Generate Trivy Vulnerability Report
```bash
docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/sbom-output:/sbom-output \
    syft-trivy-sbom:latest \
    trivy image --format json nginx:latest > sbom-output/vulnerabilities.json
```

### 4. Interactive Shell
```bash
docker run -it --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/sbom-output:/sbom-output \
    syft-trivy-sbom:latest \
    /bin/bash
```

## Test with Local Repository

To scan a local repository/codebase:

### 1. Using Trivy for Filesystem Scanning
```bash
docker run --rm \
    -v /path/to/your/repo:/scan \
    syft-trivy-sbom:latest \
    trivy fs /scan
```

### 2. Using Syft for Filesystem
```bash
docker run --rm \
    -v /path/to/your/repo:/scan \
    syft-trivy-sbom:latest \
    syft /scan
```

### 3. Scanning a Git Repository
```bash
docker run --rm \
    -v /path/to/your/repo:/repo \
    syft-trivy-sbom:latest \
    trivy fs /repo --format json > sbom-output/repo-scan.json
```

## Viewing Generated SBOMs

The generated files will be in `sbom-output/`:

```bash
# List all generated files
ls -lh sbom-output/

# View JSON SBOM (formatted)
cat sbom-output/sbom.json | jq .

# View vulnerabilities
cat sbom-output/vulnerabilities.json | jq .

# Count components in SBOM
cat sbom-output/sbom.json | jq '.components | length'
```

## Troubleshooting

### Docker Daemon Not Running
```bash
# Check Docker status
docker ps

# If error, start Docker:
sudo systemctl start docker  # Linux
# or open Docker Desktop app
```

### Permission Denied
If you get permission denied errors:
```bash
# Add your user to docker group (Linux)
sudo usermod -aG docker $USER
newgrp docker

# Or run with sudo
sudo ./test.sh
```

### Image Not Found
If the test image doesn't exist locally:
```bash
# Pull the image first
docker pull nginx:latest
./test.sh nginx:latest
```

## Next Steps

After testing:
1. Review the generated SBOM files in `sbom-output/`
2. Check the vulnerability reports
3. Customize the Dockerfile if needed
4. Deploy to your CI/CD pipeline
