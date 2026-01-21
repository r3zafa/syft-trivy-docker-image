
#!/bin/bash

# Docker Registry Publishing Script
# Publishes syft-trivy-sbom image to Docker registries
# Supports: Docker Hub, Azure Container Registry (ACR), GitHub Container Registry

set -eu


# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function print_header() {
  echo -e "${BLUE}[*] $1${NC}"
}

function print_success() {
  echo -e "${GREEN}[✓] $1${NC}"
}

function print_warning() {
  echo -e "${YELLOW}[!] $1${NC}"
}

function print_error() {
  echo -e "${RED}[✗] $1${NC}"
}

# --- HELP MESSAGE ---
if [[ $# -eq 0 ]]; then
  print_error "No arguments provided."
  print_warning "Usage: ./publish.sh REGISTRY [--version VERSION]"
  print_warning "Try './publish.sh --help' for more information."
  exit 1
fi

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  cat << EOF
Usage: ./publish.sh REGISTRY [--version VERSION]

REGISTRY (required positional argument):
  dockerhub       Docker Hub (default)
  acr             Azure Container Registry
  ghcr            GitHub Container Registry

Options:
  --version       Image version tag (default: 1.1.0)
  --help, -h      Show this help

Behavior:
  - You must be logged in to Docker (via 'docker login') before running this script.
  - The script will fail with a clear message if you are not logged in.
  - Only the --version option is supported in addition to the required REGISTRY argument.

Examples:
  ./publish.sh dockerhub
  ./publish.sh dockerhub --version 2.0.0
  ./publish.sh acr --version 2.0.0
  ./publish.sh ghcr
EOF
  exit 0
fi

# Image and versioning
DOCKER_IMAGE="r3zafa/syft-trivy-sbom:latest"
DOCKER_TAG="latest"

DOCKER_VERSION=""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function print_header() {
  echo -e "${BLUE}[*] $1${NC}"
}

function print_success() {
  echo -e "${GREEN}[✓] $1${NC}"
}

function print_warning() {
  echo -e "${YELLOW}[!] $1${NC}"
}

function print_error() {
  echo -e "${RED}[✗] $1${NC}"
}

# Parse arguments
REGISTRY=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --version)
      DOCKER_VERSION="$2"
      shift 2
      ;;
    --help|-h)
      # Already handled above
      shift
      ;;
    dockerhub|acr|ghcr)
      REGISTRY="$1"
      shift
      ;;
    *)
      echo "Unknown option or argument: $1"
      exit 1
      ;;
  esac
done

if [ -z "$DOCKER_VERSION" ]; then
  print_error "--version VERSION is required."
  print_warning "Usage: ./publish.sh REGISTRY [--version VERSION]"
  print_warning "Try './publish.sh --help' for more information."
  exit 1
fi

if [ -z "$REGISTRY" ]; then
  echo "Error: REGISTRY positional argument is required."
  echo "Run ./publish.sh --help for usage."
  exit 1
fi

# --- Docker login check ---
print_header "Checking Docker login..."
if ! docker info 2>&1 | grep -q 'Username:'; then
  print_error "Not logged in to Docker. Please run 'docker login' first."
  exit 1
fi
print_success "Docker login detected."

function publish_dockerhub() {
  local repo="r3zafa/syft-trivy-sbom"
  print_header "Publishing to Docker Hub: $repo"
  print_header "Tagging image..."
  docker tag "$DOCKER_IMAGE" "$repo:latest"
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_VERSION"
  print_success "Image tagged"
  print_header "Pushing to Docker Hub..."
  docker push "$repo:latest"
  docker push "$repo:$DOCKER_VERSION"
  print_success "Pushed to Docker Hub"
  echo ""
  echo "Available at:"
  echo "  docker pull $repo:latest"
  echo "  docker pull $repo:$DOCKER_VERSION"
}

function publish_acr() {
  local repo="r3zafa/syft-trivy-sbom"
  print_header "Publishing to Azure Container Registry: $repo"
  print_header "Tagging image..."
  docker tag "$DOCKER_IMAGE" "$repo:latest"
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_VERSION"
  print_success "Image tagged"
  print_header "Pushing to ACR..."
  docker push "$repo:latest"
  docker push "$repo:$DOCKER_VERSION"
  print_success "Pushed to ACR"
  echo ""
  echo "Available at:"
  echo "  docker pull $repo:latest"
  echo "  docker pull $repo:$DOCKER_VERSION"
}

function publish_ghcr() {
  local repo="r3zafa/syft-trivy-sbom"
  print_header "Publishing to GitHub Container Registry: $repo"
  print_header "Tagging image..."
  docker tag "$DOCKER_IMAGE" "$repo:latest"
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_VERSION"
  print_success "Image tagged"
  print_header "Pushing to GHCR..."
  docker push "$repo:latest"
  docker push "$repo:$DOCKER_VERSION"
  print_success "Pushed to GHCR"
  echo ""
  echo "Available at:"
  echo "  docker pull $repo:latest"
  echo "  docker pull $repo:$DOCKER_VERSION"
}

case "$REGISTRY" in
  dockerhub)
    publish_dockerhub
    ;;
  acr)
    publish_acr
    ;;
  ghcr)
    publish_ghcr
    ;;
  *)
    print_error "Unknown registry: $REGISTRY"
    exit 1
    ;;
esac

print_success "Image published successfully!"
