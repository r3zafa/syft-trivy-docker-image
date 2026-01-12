#!/bin/bash

# Docker Registry Publishing Script
# Publishes syft-trivy-sbom image to Docker registries
# Supports: Docker Hub, Azure Container Registry (ACR), GitHub Container Registry

set -e

DOCKER_IMAGE="syft-trivy-sbom:latest"
DOCKER_TAG="latest"
DOCKER_VERSION="1.0.0"

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

function show_usage() {
  cat << EOF
Usage: ./publish.sh [REGISTRY] [OPTIONS]

Registries:
  dockerhub       Docker Hub (default)
  acr             Azure Container Registry
  ghcr            GitHub Container Registry

Options:
  --username      Docker Hub username
  --registry      ACR registry URL (e.g., myregistry.azurecr.io)
  --token         Registry token/password
  --help          Show this help

Examples:
  # Docker Hub
  ./publish.sh dockerhub --username myusername

  # Azure Container Registry
  ./publish.sh acr --registry myregistry.azurecr.io --username myusername --token mytoken

  # GitHub Container Registry
  ./publish.sh ghcr --username myusername --token mytoken

EOF
  exit 0
}

function login_dockerhub() {
  local username=$1
  if [ -z "$username" ]; then
    print_error "Docker Hub username required"
    echo "Usage: ./publish.sh dockerhub --username <your-username>"
    exit 1
  fi
  
  print_header "Logging in to Docker Hub..."
  docker login -u "$username"
  print_success "Logged in to Docker Hub"
}

function publish_dockerhub() {
  local username=$1
  
  if [ -z "$username" ]; then
    print_error "Docker Hub username required"
    exit 1
  fi
  
  local registry="docker.io"
  local repo="$username/syft-trivy-sbom"
  
  print_header "Publishing to Docker Hub: $repo"
  
  # Tag image
  print_header "Tagging image..."
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_TAG"
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_VERSION"
  docker tag "$DOCKER_IMAGE" "$repo:latest"
  print_success "Image tagged"
  
  # Push images
  print_header "Pushing to Docker Hub..."
  docker push "$repo:$DOCKER_TAG"
  docker push "$repo:$DOCKER_VERSION"
  docker push "$repo:latest"
  print_success "Pushed to Docker Hub"
  
  echo ""
  echo "Available at:"
  echo "  docker pull $repo:$DOCKER_TAG"
  echo "  docker pull $repo:$DOCKER_VERSION"
  echo "  docker pull $repo:latest"
}

function publish_acr() {
  local registry=$1
  local username=$2
  local token=$3
  
  if [ -z "$registry" ] || [ -z "$username" ] || [ -z "$token" ]; then
    print_error "ACR requires: --registry, --username, --token"
    exit 1
  fi
  
  print_header "Publishing to Azure Container Registry: $registry"
  
  # Login to ACR
  print_header "Logging in to ACR..."
  echo "$token" | docker login -u "$username" --password-stdin "$registry"
  print_success "Logged in to ACR"
  
  # Tag image
  local repo="$registry/syft-trivy-sbom"
  print_header "Tagging image..."
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_TAG"
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_VERSION"
  docker tag "$DOCKER_IMAGE" "$repo:latest"
  print_success "Image tagged"
  
  # Push images
  print_header "Pushing to ACR..."
  docker push "$repo:$DOCKER_TAG"
  docker push "$repo:$DOCKER_VERSION"
  docker push "$repo:latest"
  print_success "Pushed to ACR"
  
  echo ""
  echo "Available at:"
  echo "  docker pull $repo:$DOCKER_TAG"
  echo "  docker pull $repo:$DOCKER_VERSION"
  echo "  docker pull $repo:latest"
}

function publish_ghcr() {
  local username=$1
  local token=$2
  
  if [ -z "$username" ] || [ -z "$token" ]; then
    print_error "GHCR requires: --username, --token"
    exit 1
  fi
  
  local registry="ghcr.io"
  local repo="$registry/$username/syft-trivy-sbom"
  
  print_header "Publishing to GitHub Container Registry: $repo"
  
  # Login to GHCR
  print_header "Logging in to GHCR..."
  echo "$token" | docker login -u "$username" --password-stdin "$registry"
  print_success "Logged in to GHCR"
  
  # Tag image
  print_header "Tagging image..."
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_TAG"
  docker tag "$DOCKER_IMAGE" "$repo:$DOCKER_VERSION"
  docker tag "$DOCKER_IMAGE" "$repo:latest"
  print_success "Image tagged"
  
  # Push images
  print_header "Pushing to GHCR..."
  docker push "$repo:$DOCKER_TAG"
  docker push "$repo:$DOCKER_VERSION"
  docker push "$repo:latest"
  print_success "Pushed to GHCR"
  
  echo ""
  echo "Available at:"
  echo "  docker pull $repo:$DOCKER_TAG"
  echo "  docker pull $repo:$DOCKER_VERSION"
  echo "  docker pull $repo:latest"
}

# Parse arguments
if [ $# -eq 0 ]; then
  show_usage
fi

REGISTRY="${1:-.}"
USERNAME=""
REGISTRY_URL=""
TOKEN=""

shift || true

while [[ $# -gt 0 ]]; do
  case $1 in
    --username)
      USERNAME="$2"
      shift 2
      ;;
    --registry)
      REGISTRY_URL="$2"
      shift 2
      ;;
    --token)
      TOKEN="$2"
      shift 2
      ;;
    --help)
      show_usage
      ;;
    *)
      print_error "Unknown option: $1"
      show_usage
      ;;
  esac
done

case "$REGISTRY" in
  dockerhub)
    login_dockerhub "$USERNAME"
    publish_dockerhub "$USERNAME"
    ;;
  acr)
    publish_acr "$REGISTRY_URL" "$USERNAME" "$TOKEN"
    ;;
  ghcr)
    publish_ghcr "$USERNAME" "$TOKEN"
    ;;
  help)
    show_usage
    ;;
  *)
    print_error "Unknown registry: $REGISTRY"
    show_usage
    ;;
esac

print_success "Image published successfully!"
