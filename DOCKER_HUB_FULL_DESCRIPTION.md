# Docker Hub Full Description - Syft & Trivy SBOM Generator

**Copy everything below and paste into the Docker Hub repository description field:**

---

## Syft & Trivy Docker SBOM Generator

A pre-configured Docker image combining industry-leading security tools for Software Bill of Materials (SBOM) generation and vulnerability scanning.

### 🔍 What's Inside

**Syft v1.40.0** - Generate comprehensive SBOMs in multiple formats:
- SPDX 2.3 JSON (compliance standard)
- CycloneDX 1.4+ (industry standard)
- Syft JSON (detailed analysis)

**Trivy v0.53.0** - Detect vulnerabilities in:
- Container images
- Filesystems and source code
- OS packages and dependencies

### 🚀 Quick Start

**Pull the image:**
```bash
docker pull r3zafa/syft-trivy-sbom:latest
```

**Generate SBOM:**
```bash
docker run -v $(pwd)/project:/project r3zafa/syft-trivy-sbom:latest \
  syft /project -o spdx-json
```

**Scan for vulnerabilities:**
```bash
docker run r3zafa/syft-trivy-sbom:latest \
  trivy image nginx:latest
```

### 📋 Key Features

✅ **Multiple SBOM Formats** - SPDX, CycloneDX, Syft JSON
✅ **Vulnerability Detection** - CVE scanning with CVSS scores
✅ **CI/CD Ready** - Docker Compose, Kubernetes, Azure DevOps
✅ **Compliance Focused** - NIST EO 14028 compliant
✅ **Enterprise Integration** - Azure DevOps template support
✅ **Production Tested** - Validated against real projects

### 🎯 Use Cases

- **Supply Chain Security** - Track dependencies, identify risks
- **Compliance & Auditing** - Generate standardized SBOMs
- **Vulnerability Management** - Detect and report security issues
- **CI/CD Pipelines** - Automate security scanning
- **License Compliance** - Track component licenses
- **Risk Assessment** - Understand software composition

### 📦 Technical Specs

| Component | Version |
|-----------|---------|
| Base Image | Ubuntu 24.04 LTS |
| Syft | v1.40.0 |
| Trivy | v0.53.0 |
| Size | 497MB (120MB compressed) |

### 💻 Usage Examples

**Generate CycloneDX SBOM:**
```bash
docker run -v $(pwd)/project:/project r3zafa/syft-trivy-sbom:latest \
  syft /project -o cyclonedx
```

**Detailed vulnerability report:**
```bash
docker run r3zafa/syft-trivy-sbom:latest \
  trivy image --format json --severity HIGH,CRITICAL nginx:latest
```

**List all dependencies:**
```bash
docker run -v $(pwd)/project:/project r3zafa/syft-trivy-sbom:latest \
  syft /project
```

### 🔗 Integration

**Docker Compose:**
```yaml
version: '3.8'
services:
  sbom-generator:
    image: r3zafa/syft-trivy-sbom:latest
    volumes:
      - ./project:/project
      - ./sbom-output:/sbom-output
    command: syft /project -o spdx-json
```

**Azure DevOps Pipeline:**
```yaml
- task: Docker@2
  inputs:
    command: 'pull'
    repository: 'r3zafa/syft-trivy-sbom'
    tags: 'latest'

- script: |
    docker run -v $(Build.SourcesDirectory):/project \
      r3zafa/syft-trivy-sbom:latest \
      syft /project -o spdx-json
```

### 📚 Documentation

- **GitHub Repository**: https://github.com/aerzendigitalsystems/syft-trivy-docker-image
- **README**: Quick start guide and usage examples
- **Full Docs**: Configuration, testing, and enterprise integration guides
- **Issue Tracker**: Report bugs or request features

### ✅ Tested & Verified

- ✓ SBOM generation in all formats
- ✓ Vulnerability scanning accuracy
- ✓ Docker Hub publication
- ✓ Azure DevOps integration
- ✓ CI/CD pipeline compatibility

### 🎓 Supported Standards

- **SPDX 2.3** - Software Package Data Exchange
- **CycloneDX 1.4+** - Component transparency
- **NIST EO 14028** - Secure software development framework
- **Supply Chain Security** - Industry best practices

### 🛠️ Perfect For

- DevOps engineers implementing supply chain security
- Security teams managing vulnerability assessments
- Compliance teams tracking software composition
- Development teams analyzing dependencies
- Enterprise organizations requiring SBOM generation

### 📞 Support

For issues, questions, or contributions:
- Visit the GitHub repository
- Check documentation for configuration options
- Review test results for validation details

### 🎉 Get Started Today

Pull and use immediately:
```bash
docker pull r3zafa/syft-trivy-sbom:latest
```

No setup required. All tools pre-installed and tested.

---

**Version:** 1.0.0 | **Updated:** January 12, 2026

