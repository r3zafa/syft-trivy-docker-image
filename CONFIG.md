# Syft & Trivy SBOM Generator - Quick Start Guide

## Overview

This is a configurable Docker-based solution for generating Software Bill of Materials (SBOMs) and security vulnerability reports using Syft and Trivy. It works with any project or Docker image - **no hardcoding for specific projects**.

## Installation

### Build the Image

```bash
./build.sh                    # Build with default tag: syft-trivy-sbom:latest
./build.sh my-sbom:v1.0      # Build with custom tag
```

## Configuration

### Using Environment Variables with Docker Compose

Create a `.env` file (copy from `.env.example`):

```bash
cp .env.example .env
```

Edit `.env` with your project details:

```env
PROJECT_NAME=my-project
PROJECT_PATH=/path/to/your/project
OUTPUT_DIR=./sbom-output
```

Then run:

```bash
docker-compose up
docker-compose exec sbom-generator /bin/bash
```

### Manual Docker Run

```bash
# Scan a local project
docker run -it --rm \
  -v /path/to/project:/project \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft /project -o json > sbom-output/sbom.json

# Scan a Docker image
docker run -it --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft nginx:latest -o json > sbom-output/sbom.json
```

## Script Usage

### Using generate-sbom.sh (Standalone)

```bash
# Scan a Docker image
./generate-sbom.sh -i nginx:latest -o ./sbom-output

# Scan a local project
./generate-sbom.sh -p /path/to/project -o ./sbom-output

# Scan current directory
./generate-sbom.sh -p . -o ./sbom-output

# Help
./generate-sbom.sh -h
```

### Using test.sh (With Docker)

```bash
# Test with Docker image
./test.sh -i python:3.11 -o ./sbom-output

# Test with local project
./test.sh -p /path/to/project -o ./sbom-output

# Interactive shell
./test.sh -p /path/to/project -o ./sbom-output --shell

# Help
./test.sh -h
```

## Examples

### Example 1: Scan Bavaria Automated Testing Repo

```bash
# Using environment variables
export PROJECT_NAME=bavaria
export PROJECT_PATH=/home/r3zafa/bavaria-automated-testing
export OUTPUT_DIR=./sbom-output
docker-compose up
```

### Example 2: Scan a GitHub Repository

```bash
# Clone repo and scan
git clone https://github.com/your-org/your-repo.git
./generate-sbom.sh -p ./your-repo -o ./sbom-output/your-repo
```

### Example 3: Scan Multiple Docker Images

```bash
./generate-sbom.sh -i alpine:latest -o ./sbom-output
./generate-sbom.sh -i python:3.11 -o ./sbom-output
./generate-sbom.sh -i node:20 -o ./sbom-output
```

### Example 4: Scan with Custom Image Tag

```bash
# Build custom image
./build.sh my-scanner:prod

# Use in test
./test.sh -t my-scanner:prod -i ubuntu:22.04
```

## Output Files

For each scan, three SBOM formats are generated:

- **{project}-sbom-syft.json** - Syft JSON format (comprehensive metadata)
- **{project}-sbom-spdx.json** - SPDX-JSON format (standard compliance)
- **{project}-sbom-cyclonedx.json** - CycloneDX format (supply chain)
- **{project}-trivy-report.json** - Vulnerability scan report

File naming uses the project name or image name automatically:
- Project: `bavaria` → `bavaria-sbom-syft.json`
- Image: `nginx:latest` → `nginx-latest-sbom-syft.json`

## Continuous Integration

### GitHub Actions Example

```yaml
name: SBOM Generation

on: [push]

jobs:
  sbom:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker image
        run: ./build.sh
      
      - name: Generate SBOM
        run: |
          ./generate-sbom.sh -p . -o ./sbom-output
      
      - name: Upload SBOMs
        uses: actions/upload-artifact@v3
        with:
          name: sbom-reports
          path: sbom-output/
```

### GitLab CI Example

```yaml
sbom-generation:
  image: docker:latest
  script:
    - ./build.sh
    - ./generate-sbom.sh -p . -o ./sbom-output
  artifacts:
    paths:
      - sbom-output/
    expire_in: 30 days
```

## Advanced Usage

### Scan Only Specific File Types

```bash
# Works with both Syft and Trivy filters
docker run -it --rm \
  -v /path/to/project:/project \
  -v $(pwd)/sbom-output:/sbom-output \
  syft-trivy-sbom:latest \
  syft /project -o json | jq '.artifacts[] | select(.language=="javascript")'
```

### Custom Output Directory per Project

```bash
# Each project gets its own SBOM directory
./generate-sbom.sh -p /projects/project-a -o ./sbom-output/project-a
./generate-sbom.sh -p /projects/project-b -o ./sbom-output/project-b
```

### Batch Scanning Multiple Projects

```bash
#!/bin/bash
# scan-all-projects.sh

PROJECTS=(
  "/path/to/project-a"
  "/path/to/project-b"
  "/path/to/project-c"
)

for project in "${PROJECTS[@]}"; do
  echo "Scanning: $project"
  ./generate-sbom.sh -p "$project" -o ./sbom-output/$(basename "$project")
done
```

## Troubleshooting

### Docker Daemon Not Running

```bash
# Check status
docker ps

# Start Docker
sudo systemctl start docker          # Linux
open -a Docker                       # macOS
# Windows: Open Docker Desktop app
```

### Permission Denied

```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

### Project Path Issues

```bash
# Use absolute paths
export PROJECT_PATH=$(cd /path/to/project && pwd)
./generate-sbom.sh -p "$PROJECT_PATH"

# Or relative to docker-compose location
cd /your/docker/compose/location
./generate-sbom.sh -p ../my-project
```

## File Structure

```
syft-trivy-docker-image/
├── Dockerfile                  # Container definition
├── docker-compose.yml          # Configurable compose file
├── build.sh                    # Build script
├── generate-sbom.sh            # Standalone SBOM generator
├── test.sh                     # Docker-based test script
├── .env.example                # Environment template
├── README.md                   # This file
├── TESTING.md                  # Detailed testing guide
└── sbom-output/               # Generated SBOMs (created at runtime)
```

## Variable Reference

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `PROJECT_NAME` | Container and identifier name | `my-project` |
| `PROJECT_PATH` | Path to project to scan | `/home/user/my-project` |
| `OUTPUT_DIR` | Where to save SBOMs | `./sbom-output` |
| `TARGET_IMAGE` | Docker image to scan | `nginx:latest` |

### Script Parameters

#### generate-sbom.sh

```
-i, --image <image>    Docker image to scan
-p, --path <path>      Local project path
-o, --output <dir>     Output directory
-h, --help             Show help
```

#### test.sh

```
-i, --image <image>    Docker image to scan
-p, --path <path>      Local project path
-o, --output <dir>     Output directory
-t, --tag <tag>        Docker image tag to use
-h, --help             Show help
```

#### build.sh

```
./build.sh              Build with default tag
./build.sh <tag>       Build with custom tag
```

## Performance Tips

1. **Cache Docker images** - First scan is slower, subsequent scans are faster
2. **Use absolute paths** - Avoids symlink resolution issues
3. **Batch scans** - Scan multiple projects in sequence
4. **Archive results** - Keep SBOM history for compliance

## Security Notes

- Trivy downloads vulnerability databases on first run (~80MB)
- Docker socket is mounted for image access (read-only)
- No credentials are stored in SBOMs
- All scanning happens locally

## Support and Documentation

- **Syft**: https://github.com/anchore/syft
- **Trivy**: https://github.com/aquasecurity/trivy
- **SPDX**: https://spdx.dev
- **CycloneDX**: https://cyclonedx.org

---

**Version**: 1.0  
**Last Updated**: January 2026
