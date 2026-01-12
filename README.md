# Syft & Trivy Docker SBOM Generator

A Docker image pre-configured with **Syft** and **Trivy** for generating Software Bill of Materials (SBOMs) and vulnerability reports.

**📦 Published to Docker Hub:** [`r3zafa/syft-trivy-sbom:latest`](https://hub.docker.com/r/r3zafa/syft-trivy-sbom)

## Overview

This project provides a containerized environment with:
- **Syft v1.24.1**: Generate SBOMs in multiple formats (JSON, SPDX, CycloneDX)
- **Trivy v0.53.0**: Scan images for vulnerabilities and generate SBOMs
- **Base Image**: Ubuntu 22.04 LTS

## Quick Start

### Option 1: Use Published Image (Recommended)

```bash
docker pull r3zafa/syft-trivy-sbom:latest
```

### Option 2: Build the Image Locally

```bash
chmod +x build.sh
./build.sh
```

Or manually:

```bash
docker build -t syft-trivy-sbom:latest .
```

### Using Docker Compose

```bash
docker-compose up -d
docker-compose exec sbom-generator /bin/bash
```

### Using Docker Directly

```bash
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  /bin/bash
```

## Usage Examples

### Generate Syft SBOM (JSON)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest -o json > sbom-output/nginx-sbom.json
```

### Generate Syft SBOM (SPDX)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest -o spdx > sbom-output/nginx-sbom.spdx.json
```

### Generate Syft SBOM (CycloneDX)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest -o cyclonedx > sbom-output/nginx-sbom.cyclonedx.json
```

### Generate Trivy Vulnerability Report

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  trivy image --format json nginx:latest > sbom-output/vulnerabilities.json
```

### Generate Complete SBOM Reports

Use the provided script:

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  /app/generate-sbom.sh /sbom-output nginx:latest
```

## Directory Structure

```
.
├── Dockerfile                 # Multi-stage Dockerfile with Syft & Trivy
├── docker-compose.yml         # Docker Compose configuration
├── build.sh                   # Build script
├── generate-sbom.sh          # SBOM generation script
├── README.md                 # This file
└── sbom-output/              # Output directory for generated SBOMs (created at runtime)
```

## Supported SBOM Formats

### Syft
- **JSON**: Standard JSON format for machine parsing
- **SPDX**: Software Package Data Exchange format (JSON)
- **CycloneDX**: CycloneDX format (JSON)

### Trivy
- **CycloneDX**: CycloneDX format
- **SARIF**: Static Analysis Results Format
- **JSON**: Vulnerability details in JSON format
- **Table**: Human-readable table format

## Tools Information

- **Syft**: Container and artifact SBOM tool
  - GitHub: https://github.com/anchore/syft
  - Latest version detection and automatic installation

- **Trivy**: Vulnerability scanner for containers and code
  - GitHub: https://github.com/aquasecurity/trivy
  - Pre-configured for image scanning

## Requirements

- Docker 20.10+
- Docker Compose 1.29+ (optional, for compose setup)
- Docker daemon access (mounted via socket)

## Environment Variables

No special environment variables required. The container uses standard PATH configuration.

## Troubleshooting

### Docker Socket Access
Make sure to mount the Docker socket when running containers:
```bash
-v /var/run/docker.sock:/var/run/docker.sock
```

### Permission Issues
If you encounter permission issues:
```bash
# Run with user context
docker run --rm --user $(id -u):$(id -g) \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest -o json
```

### Image Size
The image is built on Alpine Linux 3.18 for minimal size while maintaining tool functionality.

## License

This project is provided as-is for educational and production use.
