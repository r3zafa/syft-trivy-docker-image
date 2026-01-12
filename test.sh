#!/bin/bash

# Test Script - Run SBOM generation for any project or Docker image
# Usage: ./test.sh [OPTIONS]
# Options:
#   -i, --image <image>     Docker image to scan (default: nginx:latest)
#   -p, --path <path>       Local project path to scan
#   -o, --output <dir>      Output directory for SBOMs (default: ./sbom-output)
#   -t, --tag <tag>         Docker image tag (default: syft-trivy-sbom:latest)
#   -h, --help              Show this help message

set -e

DOCKER_IMAGE="syft-trivy-sbom:latest"
OUTPUT_DIR="./sbom-output"
TEST_IMAGE=""
PROJECT_PATH=""

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--image)
      TEST_IMAGE="$2"
      shift 2
      ;;
    -p|--path)
      PROJECT_PATH="$2"
      shift 2
      ;;
    -o|--output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    -t|--tag)
      DOCKER_IMAGE="$2"
      shift 2
      ;;
    -h|--help)
      grep '^#' "$0" | head -15
      exit 0
      ;;
    *)
      TEST_IMAGE="$1"
      shift
      ;;
  esac
done

# Set default if neither image nor path specified
if [ -z "$TEST_IMAGE" ] && [ -z "$PROJECT_PATH" ]; then
  TEST_IMAGE="nginx:latest"
fi

echo "========================================"
echo "Testing Syft & Trivy SBOM Generator"
echo "========================================"
echo ""

# Check if Docker is running
if ! docker ps > /dev/null 2>&1; then
    echo "[ERROR] Docker daemon is not running!"
    echo ""
    echo "Please start Docker first:"
    echo "  - For RancherDesktop: Open RancherDesktop application"
    echo "  - For Docker Desktop: Open Docker Desktop application"
    echo "  - For Linux: sudo systemctl start docker"
    exit 1
fi

echo "[*] Docker daemon is running ✓"
echo ""

# Check if image exists
if ! docker image inspect "$DOCKER_IMAGE" > /dev/null 2>&1; then
    echo "[*] Building Docker image: $DOCKER_IMAGE"
    docker build -t "$DOCKER_IMAGE" .
    echo "[✓] Image built successfully"
else
    echo "[✓] Image already exists: $DOCKER_IMAGE"
fi

echo ""

mkdir -p "$OUTPUT_DIR"

if [ -n "$PROJECT_PATH" ]; then
  echo "[*] Testing with project: $PROJECT_PATH"
  SCAN_TARGET="$PROJECT_PATH"
  SCAN_TYPE="filesystem"
else
  echo "[*] Testing with image: $TEST_IMAGE"
  SCAN_TARGET="$TEST_IMAGE"
  SCAN_TYPE="image"
fi

echo ""
echo "Step 1: Generate Syft SBOM (JSON format) - $SCAN_TYPE"
if [ "$SCAN_TYPE" = "image" ]; then
  docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$(pwd)/$OUTPUT_DIR:/sbom-output" \
      "$DOCKER_IMAGE" \
      syft "$SCAN_TARGET" -o json > "$OUTPUT_DIR/test-sbom-syft.json"
else
  docker run --rm \
      -v "$(cd "$PROJECT_PATH" && pwd):/project" \
      -v "$(pwd)/$OUTPUT_DIR:/sbom-output" \
      "$DOCKER_IMAGE" \
      syft /project -o json > "$OUTPUT_DIR/test-sbom-syft.json"
fi
echo "[✓] Generated: $OUTPUT_DIR/test-sbom-syft.json"

echo ""
echo "Step 2: Generate Syft SBOM (SPDX format) - $SCAN_TYPE"
if [ "$SCAN_TYPE" = "image" ]; then
  docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$(pwd)/$OUTPUT_DIR:/sbom-output" \
      "$DOCKER_IMAGE" \
      syft "$SCAN_TARGET" -o spdx-json > "$OUTPUT_DIR/test-sbom-spdx.json"
else
  docker run --rm \
      -v "$(cd "$PROJECT_PATH" && pwd):/project" \
      -v "$(pwd)/$OUTPUT_DIR:/sbom-output" \
      "$DOCKER_IMAGE" \
      syft /project -o spdx-json > "$OUTPUT_DIR/test-sbom-spdx.json"
fi
echo "[✓] Generated: $OUTPUT_DIR/test-sbom-spdx.json"

echo ""
echo "Step 3: Generate vulnerability report"
if [ "$SCAN_TYPE" = "image" ]; then
  docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      -v "$(pwd)/$OUTPUT_DIR:/sbom-output" \
      "$DOCKER_IMAGE" \
      trivy image --format json "$SCAN_TARGET" > "$OUTPUT_DIR/test-vulnerabilities.json"
else
  docker run --rm \
      -v "$(cd "$PROJECT_PATH" && pwd):/project" \
      -v "$(pwd)/$OUTPUT_DIR:/sbom-output" \
      "$DOCKER_IMAGE" \
      trivy fs /project --format json > "$OUTPUT_DIR/test-vulnerabilities.json"
fi
echo "[✓] Generated: $OUTPUT_DIR/test-vulnerabilities.json"

echo ""
echo "========================================"
echo "Test completed successfully!"
echo "========================================"
echo ""
echo "Generated files:"
ls -lh "$OUTPUT_DIR"/test-*
echo ""
echo "Sample content preview:"
echo ""
echo "=== Syft SBOM (JSON) Sample ==="
head -20 "$OUTPUT_DIR/test-sbom-syft.json" | jq . 2>/dev/null || head -20 "$OUTPUT_DIR/test-sbom-syft.json"
