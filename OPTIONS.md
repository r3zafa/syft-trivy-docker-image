# Complete Options Reference

This document provides a comprehensive guide to all command-line options for Syft and Trivy tools.

## Table of Contents

1. [SYFT Options](#syft-options)
2. [TRIVY Options](#trivy-options)
3. [Target Types](#target-types)
4. [Output Formats](#output-formats)
5. [Common Use Cases](#common-use-cases)

---

## SYFT Options

### Basic Syntax

```bash
syft [TARGET] [FLAGS]
```

### Output Options

| Option | Short | Description | Example |
|--------|-------|-------------|---------|
| `--output` | `-o` | Output format | `syft image:tag -o json` |
| `--file` | `-f` | Output file path | `syft image:tag -o json -f sbom.json` |
| `--quiet` | `-q` | Suppress non-essential output | `syft image:tag -q -o json` |

### Scope Options

| Option | Description | Example |
|--------|-------------|---------|
| `--scope` | Scan scope (all, squashed, layer) | `syft image:tag --scope all` |
| `--include` | Include specific file patterns | `syft image:tag --include "*.go"` |
| `--exclude` | Exclude specific file patterns | `syft image:tag --exclude "*.git"` |

### Configuration Options

| Option | Description | Example |
|--------|-------------|---------|
| `--config` | Configuration file path | `syft image:tag --config ./syft.yaml` |
| `--db` | Custom vulnerability database | `syft image:tag --db ./db.tar.gz` |

### Filtering Options

| Option | Description | Example |
|--------|-------------|---------|
| `--fail-on` | Exit with error on condition | `syft image:tag --fail-on high` |
| `--fail-on-severity` | Fail on severity level | `syft image:tag --fail-on-severity critical` |

### Logging Options

| Option | Description | Example |
|--------|-------------|---------|
| `--verbose` | `-v` | Verbose output | `syft image:tag -v` |
| `--debug` | `-d` | Debug mode | `syft image:tag -d` |
| `--log-level` | Set log level | `syft image:tag --log-level debug` |

### Format-Specific Options

#### JSON Format (`-o json`)
```bash
syft nginx:latest -o json
```

#### SPDX Format (`-o spdx` or `-o spdx-json`)
```bash
syft nginx:latest -o spdx-json
# Also available: spdx-xml, spdx-rdf, spdx-tagvalue
```

#### CycloneDX Format (`-o cyclonedx`)
```bash
syft nginx:latest -o cyclonedx
# Also available: cyclonedx-xml, cyclonedx-json
```

#### Text/Table Formats
```bash
syft nginx:latest -o text      # Text output
syft nginx:latest -o table     # ASCII table
syft nginx:latest              # Default (similar to text)
```

### Example Commands

```bash
# Generate SBOM in JSON format
syft nginx:latest -o json > sbom.json

# Generate SBOM with verbose output
syft nginx:latest -o json -v

# Generate SBOM from directory
syft /path/to/project -o spdx-json

# Generate and save to file
syft nginx:latest -o json -f sbom.json

# Scan specific scope layers
syft nginx:latest --scope squashed -o json

# Exclude specific files
syft /project --exclude "node_modules/**" -o json

# Debug mode with specific severity
syft nginx:latest -d --fail-on critical
```

---

## TRIVY Options

### Basic Syntax

```bash
trivy [COMMAND] [TARGET] [FLAGS]
```

### Commands

| Command | Purpose |
|---------|---------|
| `image` | Scan container images |
| `fs` | Scan filesystems/directories |
| `config` | Scan Infrastructure as Code |
| `repo` | Scan Git repositories |
| `rootfs` | Scan rootfs |
| `sbom` | Generate SBOM |

### Global Options

| Option | Description | Example |
|--------|-------------|---------|
| `--format` | Output format | `trivy image --format json nginx:latest` |
| `--severity` | Filter by severity | `trivy image --severity HIGH,CRITICAL nginx:latest` |
| `--skip-update` | Skip updating DB | `trivy image --skip-update nginx:latest` |
| `--offline-scan` | Offline mode | `trivy image --offline-scan nginx:latest` |

### Severity Options

```bash
# Single severity
trivy image --severity CRITICAL nginx:latest

# Multiple severities
trivy image --severity HIGH,CRITICAL nginx:latest

# All severities
trivy image --severity UNKNOWN,LOW,MEDIUM,HIGH,CRITICAL nginx:latest
```

**Severity Levels:**
- `CRITICAL` (CVSS 9.0-10.0)
- `HIGH` (CVSS 7.0-8.9)
- `MEDIUM` (CVSS 4.0-6.9)
- `LOW` (CVSS 0.1-3.9)
- `UNKNOWN` (Unknown CVSS)

### Format Options

| Format | Use Case | Example |
|--------|----------|---------|
| `json` | Machine parsing | `trivy image --format json nginx:latest` |
| `table` | Human readable | `trivy image --format table nginx:latest` |
| `sarif` | CI/CD integration | `trivy image --format sarif nginx:latest` |
| `cyclonedx` | SBOM generation | `trivy image --format cyclonedx nginx:latest` |
| `cosign` | Binary signature | `trivy image --format cosign nginx:latest` |

### Filter Options

| Option | Description | Example |
|--------|-------------|---------|
| `--ignore-unfixed` | Hide unfixed vulnerabilities | `trivy image --ignore-unfixed nginx:latest` |
| `--include-unaffected` | Include unaffected items | `trivy image --include-unaffected nginx:latest` |
| `--skip-files` | Skip files | `trivy image --skip-files "*.md" nginx:latest` |
| `--skip-dirs` | Skip directories | `trivy image --skip-dirs "/test/**" nginx:latest` |

### Database Options

| Option | Description | Example |
|--------|-------------|---------|
| `--db-repository` | Custom DB repository | `trivy image --db-repository myrepo/trivy-db nginx:latest` |
| `--skip-db-update` | Skip DB update | `trivy image --skip-db-update nginx:latest` |
| `--cache-dir` | Cache directory | `trivy image --cache-dir /custom/cache nginx:latest` |
| `--timeout` | Scan timeout | `trivy image --timeout 5m nginx:latest` |

### Scan Configuration

| Option | Description | Example |
|--------|-------------|---------|
| `--vulnType` | Vulnerability type | `trivy image --vulnType os,library nginx:latest` |
| `--security-checks` | Check types | `trivy image --security-checks vuln,config nginx:latest` |
| `--exit-code` | Exit code on findings | `trivy image --exit-code 1 --severity HIGH nginx:latest` |

### Output Options

| Option | Description | Example |
|--------|-------------|---------|
| `--output` | `-o` | Output file | `trivy image -o report.json nginx:latest` |
| `--template` | Custom template | `trivy image --template @/path/template.tpl nginx:latest` |
| `--list-all-pkgs` | List all packages | `trivy image --list-all-pkgs nginx:latest` |

### Image-Specific Options

```bash
# Scan remote image
trivy image nginx:latest

# Scan with auth
trivy image --registry-token mytoken myregistry/image:tag

# Scan with insecure registry
trivy image --insecure myregistry/image:tag

# Scan saved image
trivy image --input saved-image.tar

# Scan image from Docker daemon
trivy image alpine:latest
```

### Filesystem Options

```bash
# Scan directory
trivy fs /path/to/project

# Scan with specific security checks
trivy fs /path/to/project --security-checks vuln,config

# Scan and fail on critical
trivy fs /path/to/project --exit-code 1 --severity CRITICAL
```

### Example Commands

```bash
# Basic image scan
trivy image nginx:latest

# JSON output with critical/high only
trivy image --format json --severity HIGH,CRITICAL nginx:latest

# Scan filesystem
trivy fs --format json /path/to/project > vulnerabilities.json

# Scan with exit code for CI/CD
trivy image --exit-code 1 --severity CRITICAL nginx:latest

# Generate SBOM
trivy image --format cyclonedx nginx:latest > sbom.json

# Scan with timeout
trivy image --timeout 10m nginx:latest

# Scan and ignore unfixed
trivy image --ignore-unfixed --severity HIGH nginx:latest

# Detailed table output
trivy image --format table --list-all-pkgs nginx:latest

# Offline scan (no DB update)
trivy image --skip-db-update --offline-scan nginx:latest
```

---

## Target Types

### Docker Images

```bash
# Official/Public images
syft nginx:latest
trivy image nginx:latest

# Registry images
syft myregistry.com/myimage:tag
trivy image myregistry.com/myimage:tag

# Docker daemon images
syft docker:myimage:tag
trivy image --input saved-image.tar
```

### Local Paths

```bash
# Directory
syft /path/to/directory
trivy fs /path/to/directory

# Tarball (Syft only)
syft tar:/path/to/file.tar.gz

# OCI image (Syft only)
syft oci:/path/to/oci/image
```

### Remote Repositories

```bash
# GitHub repo (Trivy only)
trivy repo https://github.com/user/repo

# Rootfs (Trivy only)
trivy rootfs /path/to/rootfs
```

---

## Output Formats

### JSON Format

**Syft:**
```bash
syft nginx:latest -o json
```

**Trivy:**
```bash
trivy image --format json nginx:latest
```

**Output structure:**
```json
{
  "artifacts": [
    {
      "name": "package-name",
      "version": "1.0.0",
      "type": "library",
      "language": "java"
    }
  ]
}
```

### SPDX Format

**Syft:**
```bash
syft nginx:latest -o spdx-json
```

**Formats available:**
- `spdx-json` - SPDX JSON format
- `spdx-xml` - SPDX XML format
- `spdx-tagvalue` - SPDX tag-value format

### CycloneDX Format

**Syft:**
```bash
syft nginx:latest -o cyclonedx
```

**Trivy:**
```bash
trivy image --format cyclonedx nginx:latest
```

### Table Format

```bash
# Syft
syft nginx:latest -o table

# Trivy
trivy image --format table nginx:latest
```

**Output example:**
```
NAME                 VERSION      TYPE
nginx                1.21.0       OS Package
openssl              1.1.1k       Library
zlib                 1.2.11       Library
```

---

## Common Use Cases

### Generate Complete SBOM in All Formats

```bash
#!/bin/bash
IMAGE="nginx:latest"

syft "$IMAGE" -o json > sbom-syft.json
syft "$IMAGE" -o spdx-json > sbom-spdx.json
syft "$IMAGE" -o cyclonedx > sbom-cyclonedx.json
echo "✓ SBOMs generated"
```

### Scan for Vulnerabilities with Multiple Filters

```bash
#!/bin/bash
IMAGE="nginx:latest"

# High and critical vulnerabilities only
trivy image --format json --severity HIGH,CRITICAL "$IMAGE" > critical-vulns.json

# Ignore unfixed vulnerabilities
trivy image --ignore-unfixed --format json "$IMAGE" > fixed-vulns.json

# With timeout for CI/CD
trivy image --timeout 5m --format json "$IMAGE" > full-report.json
```

### Batch Scan Multiple Projects

```bash
#!/bin/bash
PROJECTS=("project-a" "project-b" "project-c")

for project in "${PROJECTS[@]}"; do
  echo "Scanning: $project"
  syft "/path/$project" -o spdx-json > "${project}-sbom.json"
  trivy fs --format json "/path/$project" > "${project}-vulns.json"
done
```

### CI/CD Pipeline Pattern

```bash
#!/bin/bash
set -e  # Exit on error

IMAGE="${1:-nginx:latest}"
OUTPUT_DIR="${2:-.}"

echo "Generating SBOM for: $IMAGE"
trivy image --format cyclonedx "$IMAGE" > "$OUTPUT_DIR/sbom.json"

echo "Scanning vulnerabilities..."
trivy image --exit-code 1 --severity CRITICAL "$IMAGE"

echo "✓ Scan completed successfully"
```

### Export Specific Package Data

```bash
# Extract all npm packages
syft nginx:latest -o json | jq '.artifacts[] | select(.language=="javascript")'

# Get package versions
trivy image --format json nginx:latest | \
  jq '.Results[].Packages[] | {name, version}'

# List dependencies with CVSS scores
trivy image --format json nginx:latest | \
  jq '.Results[].Vulnerabilities[] | {id, severity, cvss}'
```

---

## Tips & Tricks

1. **Speed up scans:** Use `--skip-update` to skip database updates on subsequent runs
2. **CI/CD integration:** Use `--exit-code 1` to fail pipeline on vulnerabilities
3. **Custom filtering:** Combine `jq` for JSON filtering and processing
4. **Offline scanning:** Download DB once, use `--offline-scan` mode
5. **Batch operations:** Create shell scripts for scanning multiple targets
6. **Cache management:** Use `--cache-dir` for persistent caching

---

**Last Updated:** January 2026
**Syft Version:** v1.40.0
**Trivy Version:** v0.53.0
