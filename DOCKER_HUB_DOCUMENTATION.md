# Docker Hub Repository Overview

## For: r3zafa/syft-trivy-sbom

---

## Short Description (Copy to Docker Hub)

**Max 100 characters:**
```
Syft & Trivy Docker image for SBOM generation and security scanning
```

---

## Full Description (Copy to Docker Hub)

```
A pre-configured Docker image with Syft and Trivy for Software Bill of Materials (SBOM) generation and vulnerability scanning.

🔍 **SBOM Generation**
Generate comprehensive Software Bill of Materials in multiple formats:
- SPDX 2.3 JSON
- CycloneDX 1.4/1.5
- Syft JSON format

🛡️ **Security Scanning**
Detect vulnerabilities and security issues in:
- Container images
- Filesystems and source code
- Dependencies and packages

**Technical Specifications:**
- Base Image: Ubuntu 24.04 LTS
- Syft: v1.40.0
- Trivy: v0.53.0
- Size: ~497MB (120MB compressed)

**Quick Start:**

Pull the image:
```bash
docker pull r3zafa/syft-trivy-sbom:latest
```

Generate SBOM for a project:
```bash
docker run -v $(pwd)/project:/project r3zafa/syft-trivy-sbom:latest \
  syft /project -o spdx-json
```

Scan an image for vulnerabilities:
```bash
docker run r3zafa/syft-trivy-sbom:latest \
  trivy image nginx:latest
```

**Use Cases:**
✓ CI/CD pipeline integration
✓ Supply chain security
✓ Compliance and audit reporting
✓ Vulnerability assessment
✓ License compliance tracking
✓ Software composition analysis

**Documentation:**
- GitHub: https://github.com/aerzendigitalsystems/syft-trivy-docker-image
- Full Documentation: See repository README for comprehensive guides
- Azure DevOps Integration: Available for enterprise pipelines

**Supported by:**
- Anchore Syft: https://github.com/anchore/syft
- Aqua Security Trivy: https://github.com/aquasecurity/trivy
```

---

## Categories (Select on Docker Hub)

**Primary:**
- Security

**Secondary (Optional):**
- Utilities
- Development
- Scanning & Analysis

---

## Repository Links

**Docker Hub:** https://hub.docker.com/r/r3zafa/syft-trivy-sbom

**GitHub Repository:** https://github.com/aerzendigitalsystems/syft-trivy-docker-image

**Source Project:** syft-trivy-docker-image

---

## Key Features to Highlight

### 1. **Pre-configured Tools**
   - No additional installation needed
   - Ready-to-use out of the box
   - Latest stable versions tested

### 2. **Multiple SBOM Formats**
   - SPDX JSON (standard format)
   - CycloneDX (comprehensive)
   - Syft JSON (detailed)

### 3. **Enterprise Ready**
   - Azure DevOps integration
   - CI/CD pipeline compatible
   - Comprehensive documentation
   - Regular updates

### 4. **Security Focused**
   - CVE detection
   - Vulnerability scoring
   - Compliance reporting
   - Supply chain security

---

## Usage Examples for Documentation

### Example 1: Generate SBOM
```bash
docker run --rm \
  -v $(pwd)/project:/project \
  -v $(pwd)/sbom-output:/sbom-output \
  r3zafa/syft-trivy-sbom:latest \
  syft /project -o spdx-json > sbom-output/sbom.spdx.json
```

### Example 2: Security Scan
```bash
docker run --rm \
  r3zafa/syft-trivy-sbom:latest \
  trivy image --format json nginx:latest
```

### Example 3: With Docker Compose
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

### Example 4: CI/CD Pipeline
```bash
docker pull r3zafa/syft-trivy-sbom:latest
docker run --rm \
  -v $CI_PROJECT_DIR:/project \
  -v $CI_PROJECT_DIR/sbom:/sbom-output \
  r3zafa/syft-trivy-sbom:latest \
  syft /project -o cyclonedx > $CI_PROJECT_DIR/sbom/sbom.xml
```

---

## Support & Issues

For issues, documentation, or feature requests:
- GitHub Issues: https://github.com/aerzendigitalsystems/syft-trivy-docker-image/issues
- Documentation: See repository README.md
- Integration Guide: See AZURE_DEVOPS_INTEGRATION.md

---

## Version Info

| Component | Version |
|-----------|---------|
| Syft | v1.40.0 |
| Trivy | v0.53.0 |
| Base Image | Ubuntu 24.04 LTS |
| Image Tag | latest, 1.0.0 |

---

## License & Attribution

- **Syft**: Licensed under Apache 2.0 (Anchore)
- **Trivy**: Licensed under Apache 2.0 (Aqua Security)
- **Docker Image**: Available on Docker Hub

---

## Instructions for Docker Hub Update

1. Go to: https://hub.docker.com/repository/docker/r3zafa/syft-trivy-sbom/general
2. Scroll to **"Description"** section
3. Copy the **Short Description** above and paste into the short description field
4. Copy the **Full Description** above and paste into the full description field
5. Scroll to **"Categories"** section
6. Select: **Security** (primary) + **Utilities**, **Development** (optional)
7. Scroll to bottom and click **"Save"**

That's it! Your Docker Hub repository will be fully documented.
