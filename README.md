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

### SYFT Examples

#### 1. Generate Syft SBOM (JSON Format)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest -o json > sbom-output/nginx-sbom.json
```

#### 2. Generate Syft SBOM (SPDX Format)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest -o spdx > sbom-output/nginx-sbom.spdx.json
```

#### 3. Generate Syft SBOM (CycloneDX Format)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest -o cyclonedx > sbom-output/nginx-sbom.cyclonedx.json
```

#### 4. Generate SBOM for Local Project

```bash
docker run --rm \
  -v /path/to/your/project:/project \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft /project -o spdx > sbom-output/project-sbom.json
```

#### 5. Generate SBOM and Pretty-Print

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest
```

#### 6. Query SBOM for Specific Package Type

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  syft-trivy-sbom:latest \
  syft nginx:latest -o json | jq '.artifacts[] | select(.language=="javascript")'
```

#### 7. Extract All Package Names

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  syft-trivy-sbom:latest \
  syft nginx:latest -o json | jq -r '.artifacts[].name'
```

### TRIVY Examples

#### 1. Generate Trivy Vulnerability Report (JSON)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  trivy image --format json nginx:latest > sbom-output/vulnerabilities.json
```

#### 2. Scan for CRITICAL and HIGH Severity Only

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  trivy image --severity HIGH,CRITICAL --format json nginx:latest > sbom-output/critical-vulns.json
```

#### 3. Generate Trivy SBOM (CycloneDX)

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  trivy image --format cyclonedx nginx:latest > sbom-output/trivy-sbom.json
```

#### 4. Generate Table Format Report

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  syft-trivy-sbom:latest \
  trivy image --format table nginx:latest
```

#### 5. Scan Local Filesystem

```bash
docker run --rm \
  -v /path/to/your/project:/project \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  trivy fs /project --format json > sbom-output/fs-scan.json
```

#### 6. Skip Database Updates

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  syft-trivy-sbom:latest \
  trivy image --skip-update nginx:latest --format json
```

#### 7. Scan with Exit Code for CI/CD

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  syft-trivy-sbom:latest \
  trivy image --exit-code 1 --severity HIGH,CRITICAL nginx:latest
```

### Batch & Multi-Project Scanning

#### 1. Scan Multiple Docker Images

```bash
for image in nginx:latest python:3.11 node:20; do
  docker run --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd)/sbom-output:/sbom-output \
    syft-trivy-sbom:latest \
    syft "$image" -o spdx > sbom-output/${image//:/-}-sbom.json
done
```

#### 2. Scan All Local Repositories

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  sh -c 'for img in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v none); do \
    echo "Scanning: $img"; \
    syft "$img" -o spdx > sbom-output/${img//:/-}.json; \
  done'
```

#### 3. Scan Projects in Batch

```bash
#!/bin/bash
PROJECTS=(
  "/path/to/project-a"
  "/path/to/project-b"
  "/path/to/project-c"
)

for project in "${PROJECTS[@]}"; do
  project_name=$(basename "$project")
  echo "Scanning: $project_name"
  docker run --rm \
    -v "$project:/project" \
    -v $(pwd)/sbom-output:/sbom-output \
    syft-trivy-sbom:latest \
    syft /project -o spdx > sbom-output/${project_name}-sbom.json
done
```

### Advanced Options

#### 1. Custom Output with Jq Processing

```bash
# Extract vulnerabilities with CVSS scores
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  syft-trivy-sbom:latest \
  trivy image --format json nginx:latest | \
  jq '.Results[] | select(.Vulnerabilities != null) | {Target: .Target, Vulns: .Vulnerabilities[] | {ID, Severity, CVSS}}'
```

#### 2. Generate Reports in All Formats

```bash
#!/bin/bash
IMAGE="nginx:latest"
OUTPUT_DIR="sbom-output"
mkdir -p "$OUTPUT_DIR"

echo "Generating SBOMs for: $IMAGE"
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/$OUTPUT_DIR:/$OUTPUT_DIR \
  syft-trivy-sbom:latest \
  sh -c "
    syft $IMAGE -o json > /$OUTPUT_DIR/sbom-syft.json && \
    syft $IMAGE -o spdx > /$OUTPUT_DIR/sbom-spdx.json && \
    syft $IMAGE -o cyclonedx > /$OUTPUT_DIR/sbom-cyclonedx.json && \
    trivy image --format json $IMAGE > /$OUTPUT_DIR/trivy-report.json && \
    echo 'All reports generated!'
  "
```

#### 3. Generate Complete Reports with Timestamp

```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="sbom-output/reports-$TIMESTAMP"
mkdir -p "$OUTPUT_DIR"

docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/$OUTPUT_DIR:/$OUTPUT_DIR \
  syft-trivy-sbom:latest \
  sh -c "
    syft nginx:latest -o spdx > /$OUTPUT_DIR/sbom.json && \
    trivy image --format json nginx:latest > /$OUTPUT_DIR/vulns.json && \
    echo 'Reports saved to: $OUTPUT_DIR'
  "
```

#### 4. Interactive Shell for Manual Commands

```bash
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  /bin/bash
```

### Using Helper Scripts

#### 1. Generate Complete SBOM Reports (All Formats)

```bash
./generate-sbom.sh -i nginx:latest -o ./sbom-output
```

#### 2. Scan Local Project

```bash
./generate-sbom.sh -p /path/to/project -o ./sbom-output
```

#### 3. Test with Docker Compose (Interactive)

```bash
docker-compose up -d
docker-compose exec sbom-generator /bin/bash
```

#### 4. Run Tests

```bash
./test.sh -i python:3.11 -o ./sbom-output
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

### Syft Formats
- **JSON** (`-o json`): Standard JSON format for machine parsing
- **SPDX** (`-o spdx`): Software Package Data Exchange format (JSON)
- **CycloneDX** (`-o cyclonedx`): CycloneDX format (JSON)
- **Text** (`-o text`): Human-readable text format
- **Table** (`-o table`): ASCII table format

### Trivy Formats
- **JSON** (`--format json`): Detailed vulnerability information
- **CycloneDX** (`--format cyclonedx`): CycloneDX SBOM format
- **SARIF** (`--format sarif`): Static Analysis Results Format
- **Table** (`--format table`): Human-readable table
- **Template** (`--format template`): Custom template output

## SYFT Command Options

| Option | Usage | Example |
|--------|-------|---------|
| `-o, --output` | Output format | `syft image:tag -o spdx` |
| `--file` | Include only specific files | `syft image:tag --include "*.go"` |
| `--quiet` | Suppress output (for piping) | `syft image:tag -o json --quiet` |
| `--fail-on` | Exit with code on condition | `syft image:tag --fail-on high` |

**Common Targets:**
- Docker image: `syft nginx:latest`
- Local directory: `syft /path/to/project`
- Filesystem: `syft dir:/path/to/project`
- Tarball: `syft tar:file.tar.gz`
- OCI image: `syft oci:path/to/image`

## TRIVY Command Options

| Option | Usage | Example |
|--------|-------|---------|
| `--severity` | Filter vulnerabilities | `trivy image --severity HIGH,CRITICAL nginx:latest` |
| `--format` | Output format | `trivy image --format json nginx:latest` |
| `--skip-update` | Skip DB updates | `trivy image --skip-update nginx:latest` |
| `--exit-code` | Set exit code threshold | `trivy image --exit-code 1 --severity HIGH nginx:latest` |
| `--ignore-unfixed` | Hide unfixed vulnerabilities | `trivy image --ignore-unfixed nginx:latest` |
| `--timeout` | Scan timeout | `trivy image --timeout 5m nginx:latest` |

**Severity Levels:**
- `CRITICAL`: Critical vulnerabilities (CVSS 9.0+)
- `HIGH`: High severity (CVSS 7.0-8.9)
- `MEDIUM`: Medium severity (CVSS 4.0-6.9)
- `LOW`: Low severity (CVSS 0.1-3.9)
- `UNKNOWN`: Unknown severity

**Scan Types (with `trivy`):**
- `image`: Scan Docker images
- `fs`: Scan filesystems
- `config`: Scan IaC config files
- `repo`: Scan Git repositories

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
