# Repository Overview - syft-trivy-docker-image

## Project Summary

**syft-trivy-docker-image** is a production-ready Docker image that combines two industry-leading security tools:
- **Syft** - for Software Bill of Materials (SBOM) generation
- **Trivy** - for vulnerability scanning and reporting

This project provides an easy-to-use containerized solution for supply chain security, compliance reporting, and vulnerability management.

---

## Repository Structure

```
syft-trivy-docker-image/
├── Dockerfile                          # Container image definition
├── docker-compose.yml                  # Docker Compose configuration
├── run.sh                             # Local build & run wrapper
├── publish.sh                         # Registry publishing automation
├── build.sh                           # Build script
├── generate-sbom.sh                   # SBOM generation script
├── test.sh                            # Testing script
│
├── README.md                          # Quick start guide
├── AZURE_DEVOPS_INTEGRATION.md        # Azure DevOps pipeline integration
├── REGISTRY_PUBLISHING.md             # Multi-registry publishing guide
├── DOCKER_HUB_DOCUMENTATION.md        # Docker Hub metadata (this file)
├── CONFIG.md                          # Configuration reference
├── TESTING.md                         # Testing procedures
├── TEST_RESULTS.md                    # Test results summary
│
├── sample-images/
│   └── Dockerfile.example             # Example multi-image Dockerfile
│
├── sbom-output/                       # Generated SBOM examples
│   ├── sbom-*.json                    # Various SBOM formats
│   └── react-frontend/                # Example outputs from real projects
│
└── templates/                         # Azure DevOps template files
    └── (Integration templates)
```

---

## Core Components

### 1. **Dockerfile**
- Base Image: Ubuntu 24.04 LTS
- Syft v1.40.0 (latest from Anchore)
- Trivy v0.53.0 (latest from Aqua Security)
- Pre-installed dependencies for SBOM generation
- Size: 497MB (120MB compressed)

### 2. **Execution Scripts**

| Script | Purpose |
|--------|---------|
| `run.sh` | User-friendly wrapper for all operations |
| `build.sh` | Build Docker image locally |
| `generate-sbom.sh` | Generate SBOM from projects |
| `test.sh` | Run test suite |
| `publish.sh` | Publish to Docker registries |

### 3. **Configuration**
- `docker-compose.yml` - Orchestrate services
- `.env.example` - Environment variable template
- Full parameterization for multiple projects

### 4. **Documentation**
- **README.md** - Quick start and usage
- **CONFIG.md** - Configuration options
- **AZURE_DEVOPS_INTEGRATION.md** - Enterprise pipeline setup
- **REGISTRY_PUBLISHING.md** - Registry deployment guide
- **TESTING.md** - Testing procedures
- **TEST_RESULTS.md** - Validated test outcomes

---

## Capabilities

### SBOM Generation
Generate Software Bill of Materials in multiple standards:

| Format | Description | Use Case |
|--------|-------------|----------|
| **SPDX JSON** | SPDX 2.3 standard | Compliance, auditing |
| **CycloneDX** | CycloneDX 1.4+ standard | Industry standard format |
| **Syft JSON** | Syft native format | Detailed analysis |
| **Trivy JSON** | Trivy vulnerability report | Security assessment |

### Vulnerability Scanning
- Scan Docker images
- Scan filesystems and source code
- Scan OS packages and dependencies
- Generate CVE reports with CVSS scores
- Multiple severity levels (CRITICAL, HIGH, MEDIUM, LOW)

### Output Formats
- JSON (structured data)
- SARIF (security analysis results)
- Table (human-readable)
- CycloneDX XML/JSON
- SPDX JSON

---

## Quick Reference

### Pull the Image
```bash
docker pull r3zafa/syft-trivy-sbom:latest
```

### Generate SBOM (SPDX Format)
```bash
docker run -v $(pwd)/project:/project r3zafa/syft-trivy-sbom:latest \
  syft /project -o spdx-json
```

### Scan Image for Vulnerabilities
```bash
docker run r3zafa/syft-trivy-sbom:latest \
  trivy image nginx:latest
```

### Generate CycloneDX SBOM
```bash
docker run -v $(pwd)/project:/project r3zafa/syft-trivy-sbom:latest \
  syft /project -o cyclonedx
```

### List All Installed Components
```bash
docker run r3zafa/syft-trivy-sbom:latest \
  syft /project
```

---

## Registry Locations

### Docker Hub (Public)
- **Repository**: [r3zafa/syft-trivy-sbom](https://hub.docker.com/r/r3zafa/syft-trivy-sbom)
- **Tags**: `latest`, `1.0.0`
- **Access**: Public, no authentication required
- **Size**: 120MB compressed

### Azure DevOps
- **Repository**: `ssh.dev.azure.com:v3/aerzendigitalsystems/AERprogress%20by%20Bavaria/syft-trivy-docker-image`
- **Branch**: master
- **Access**: SSH with authentication
- **Pipeline Integration**: Available via templates

---

## Integration Options

### Option 1: Docker Compose (Local Development)
```bash
docker-compose up -d
docker-compose run sbom-generator syft /project -o spdx-json
```

### Option 2: Docker Run (Single Commands)
```bash
docker run -v $(pwd):/project r3zafa/syft-trivy-sbom:latest \
  syft /project -o json
```

### Option 3: Azure DevOps Pipeline
```yaml
- task: Docker@2
  inputs:
    command: 'pull'
    repository: 'r3zafa/syft-trivy-sbom'
    tags: 'latest'

- script: |
    docker run -v $(System.DefaultWorkingDirectory):/project \
      r3zafa/syft-trivy-sbom:latest \
      syft /project -o spdx-json
```

### Option 4: CI/CD Pipeline (GitLab, GitHub Actions, Jenkins)
```bash
docker pull r3zafa/syft-trivy-sbom:latest
docker run -v $CI_PROJECT_DIR:/project r3zafa/syft-trivy-sbom:latest \
  syft /project -o spdx-json > sbom.json
```

---

## Supported Scenarios

### 1. **Supply Chain Security**
- Identify and track dependencies
- Generate SBOMs for compliance
- Detect known vulnerabilities
- Create audit trails

### 2. **Compliance & Auditing**
- Generate standardized SBOMs (SPDX, CycloneDX)
- Meet regulatory requirements (NIST, EO 14028)
- Track component licenses
- Document software composition

### 3. **Vulnerability Management**
- Scan images before deployment
- Detect CVEs and security issues
- Monitor continuous vulnerability updates
- Generate risk reports

### 4. **CI/CD Integration**
- Automate SBOM generation in pipelines
- Gate deployments on security findings
- Generate compliance reports
- Integrate with scanning tools

### 5. **Development Teams**
- Analyze project dependencies
- Understand supply chain risks
- Share SBOM with stakeholders
- Track component versions

---

## Performance Specifications

| Metric | Value |
|--------|-------|
| **Image Size** | 497MB (disk), 120MB (compressed) |
| **Build Time** | ~50 seconds |
| **Syft Scan Time** | ~2-5 seconds (typical project) |
| **Trivy Scan Time** | ~5-10 seconds (image), ~2-3 seconds (filesystem) |
| **Base OS** | Ubuntu 24.04 LTS |
| **Supported Architectures** | amd64, arm64 |

---

## Testing & Validation

### Tested Projects
- **Bavaria Automated Testing**: 49 packages, 0 vulnerabilities
- **Bavaria React Frontend**: 855 packages, verified for security
- **Official Images**: nginx, node, python (various versions)

### Validation Results
- ✅ SBOM generation in all formats (SPDX, CycloneDX, Syft JSON)
- ✅ Vulnerability scanning with accurate CVE detection
- ✅ Docker Hub publication successful
- ✅ Tool versions verified (Syft 1.40.0, Trivy 0.53.0)
- ✅ Ubuntu 24.04 compatibility confirmed

See [TEST_RESULTS.md](TEST_RESULTS.md) for detailed results.

---

## Troubleshooting

### Common Issues

**Issue**: Docker daemon not running
```bash
# Start Docker daemon or use Docker Desktop
docker ps  # Verify connection
```

**Issue**: Permission denied writing to output
```bash
# Ensure output directory is writable
chmod 777 sbom-output
```

**Issue**: Image not found
```bash
# Pull the image from Docker Hub
docker pull r3zafa/syft-trivy-sbom:latest
```

**Issue**: Out of disk space
```bash
# Clean up old images
docker image prune -a
```

For more help, see [TESTING.md](TESTING.md) and project documentation.

---

## Next Steps

1. **Quick Start**: Follow [README.md](README.md)
2. **Configuration**: Review [CONFIG.md](CONFIG.md)
3. **Pipeline Integration**: Read [AZURE_DEVOPS_INTEGRATION.md](AZURE_DEVOPS_INTEGRATION.md)
4. **Registry Publishing**: Check [REGISTRY_PUBLISHING.md](REGISTRY_PUBLISHING.md)
5. **Testing**: Run [test.sh](test.sh) locally

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-01-12 | Initial release: Ubuntu 24.04, Syft 1.40.0, Trivy 0.53.0 |
| - | 2026-01-12 | Published to Docker Hub (r3zafa/syft-trivy-sbom:latest) |
| - | 2026-01-12 | Azure DevOps integration completed |
| - | 2026-01-12 | Multi-registry publishing support added |

---

## Support & Resources

- **GitHub Repository**: https://github.com/aerzendigitalsystems/syft-trivy-docker-image
- **Docker Hub**: https://hub.docker.com/r/r3zafa/syft-trivy-sbom
- **Syft Documentation**: https://github.com/anchore/syft
- **Trivy Documentation**: https://github.com/aquasecurity/trivy
- **SPDX Standard**: https://spdx.dev/
- **CycloneDX Standard**: https://cyclonedx.org/

---

## License

This Docker image repository is provided as-is for security and compliance automation.

- **Syft**: Apache 2.0 License (Anchore)
- **Trivy**: Apache 2.0 License (Aqua Security)
- **Docker Image**: MIT License

---

## Contributing

To contribute improvements, fixes, or enhancements:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Last Updated**: January 12, 2026  
**Maintainer**: r3zafa  
**Status**: Production Ready ✅
