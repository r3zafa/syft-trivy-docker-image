#!/bin/bash

# Syft & Trivy Docker - Azure DevOps Compatible
# Works with templates from: git@ssh.dev.azure.com:v3/aerzendigitalsystems/AERprogress%20by%20Bavaria/templates
# 
# This image provides Syft and Trivy pre-installed for SBOM generation and security scanning
# integrated with Azure DevOps SBOM security templates
#
# Usage:
#   docker run --rm -v /path:/project syft-trivy-sbom:latest syft /project -o json
#   docker run --rm -v /path:/project syft-trivy-sbom:latest trivy fs /project

set -e

DOCKER_IMAGE="${DOCKER_IMAGE:-syft-trivy-sbom:latest}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function print_header() {
  echo -e "${GREEN}[*] $1${NC}"
}

function print_error() {
  echo -e "${RED}[✗] $1${NC}"
}

function print_success() {
  echo -e "${GREEN}[✓] $1${NC}"
}

case "${1:-help}" in
  build)
    print_header "Building Docker image: $DOCKER_IMAGE"
    docker build -t "$DOCKER_IMAGE" .
    print_success "Image built"
    echo ""
    echo "Next steps:"
    echo "  1. Scan a filesystem:"
    echo "     docker run --rm -v /path/to/project:/project $DOCKER_IMAGE syft /project -o json"
    echo ""
    echo "  2. Scan a Docker image:"
    echo "     docker run --rm -v /var/run/docker.sock:/var/run/docker.sock $DOCKER_IMAGE syft nginx:latest -o json"
    echo ""
    echo "  3. Use in Azure DevOps templates:"
    echo "     - stages/sbom-security.yml"
    echo "     - jobs/sbom-generate.yml"
    ;;

  scan)
    print_header "Running SBOM scan"
    docker run --rm \
      -v "${2:-.}":/project \
      -v "${3:-.}/sbom-output:/sbom-output" \
      "$DOCKER_IMAGE" \
      syft /project -o json
    print_success "Scan completed"
    ;;

  security)
    print_header "Running security scan"
    docker run --rm \
      -v "${2:-.}":/project \
      "$DOCKER_IMAGE" \
      trivy fs /project --format json
    ;;

  version|--version|-v)
    print_header "Tool versions"
    docker run --rm "$DOCKER_IMAGE" bash -c 'echo "Syft: $(syft --version)"; echo "Trivy: $(trivy --version)"'
    ;;

  test)
    print_header "Testing Docker image"
    docker run --rm "$DOCKER_IMAGE" bash -c "
      echo 'Syft version:' && syft --version && echo ''
      echo 'Trivy version:' && trivy --version
    " && print_success "All tools working" || print_error "Test failed"
    ;;

  help|--help|-h)
    cat << EOF
Usage: $(basename "$0") [COMMAND]

Commands:
  build               Build Docker image
  scan <path> [out]   Scan filesystem and generate SBOM
  security <path>     Run security scan with Trivy
  version             Show tool versions
  test                Test image
  help                Show this help

Environment Variables:
  DOCKER_IMAGE        Docker image tag (default: syft-trivy-sbom:latest)

Examples:
  # Build the image
  ./run.sh build

  # Scan a project
  ./run.sh scan /path/to/project ./sbom-output

  # Run security scan
  ./run.sh security /path/to/project

Azure DevOps Integration:
  These tools are designed to work with:
    - stages/sbom-security.yml
    - jobs/sbom-generate.yml
    - steps/sbom-tool-setup.yml

  From: git@ssh.dev.azure.com:v3/aerzendigitalsystems/AERprogress%20by%20Bavaria/templates

EOF
    ;;

  *)
    print_error "Unknown command: $1"
    echo "Run '$(basename "$0") help' for usage information"
    exit 1
    ;;
esac
