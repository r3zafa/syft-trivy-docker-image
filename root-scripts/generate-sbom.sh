#!/bin/bash

# SBOM Generation Script
# Generates SBOMs and vulnerability reports for Docker images or local projects
# Usage: ./generate-sbom.sh [OPTIONS]
# Options:
#   -i, --image <image>     Docker image to scan (default: nginx:latest)
#   -p, --path <path>       Local project path to scan
#   -o, --output <dir>      Output directory (default: ./sbom-output)
#   -h, --help              Show this help message

set -e

# Default values
OUTPUT_DIR="./sbom-output"
TARGET_IMAGE=""
PROJECT_PATH=""
SCAN_NAME="sbom"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -i|--image)
      TARGET_IMAGE="$2"
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
    -h|--help)
      grep '^#' "$0" | head -15
      exit 0
      ;;
    *)
      # Positional argument
      if [ -z "$OUTPUT_DIR" ] || [ "$OUTPUT_DIR" = "./sbom-output" ]; then
        OUTPUT_DIR="$1"
      elif [ -z "$TARGET_IMAGE" ]; then
        TARGET_IMAGE="$1"
      fi
      shift
      ;;
  esac
done

# Set defaults and determine scan type
if [ -z "$TARGET_IMAGE" ] && [ -z "$PROJECT_PATH" ]; then
  TARGET_IMAGE="nginx:latest"
fi

if [ -n "$PROJECT_PATH" ]; then
  SCAN_TARGET="$PROJECT_PATH"
  SCAN_NAME=$(basename "$PROJECT_PATH" | sed 's/[^a-zA-Z0-9]/-/g')
else
  SCAN_TARGET="$TARGET_IMAGE"
  SCAN_NAME=$(echo "$TARGET_IMAGE" | sed 's/[/:.]/-/g')
fi

echo "========================================"
echo "SBOM Generation Tool"
echo "========================================"
echo "Output Directory: $OUTPUT_DIR"
if [ -n "$PROJECT_PATH" ]; then
  echo "Project Path: $PROJECT_PATH"
  SCAN_TYPE="filesystem"
else
  echo "Target Image: $TARGET_IMAGE"
  SCAN_TYPE="image"
fi
echo "Scan Type: $SCAN_TYPE"
echo ""

mkdir -p "$OUTPUT_DIR"

# Generate Syft SBOM (JSON format)
echo "[*] Generating Syft SBOM (JSON)..."
if [ "$SCAN_TYPE" = "filesystem" ]; then
  syft "$SCAN_TARGET" -o json > "$OUTPUT_DIR/${SCAN_NAME}-sbom-syft.json"
else
  syft "$SCAN_TARGET" -o json > "$OUTPUT_DIR/${SCAN_NAME}-sbom-syft.json"
fi
echo "[✓] Syft JSON SBOM: $OUTPUT_DIR/${SCAN_NAME}-sbom-syft.json"

# Generate Syft SBOM (SPDX format)
echo "[*] Generating Syft SBOM (SPDX-JSON)..."
if [ "$SCAN_TYPE" = "filesystem" ]; then
  syft "$SCAN_TARGET" -o spdx-json > "$OUTPUT_DIR/${SCAN_NAME}-sbom-spdx.json"
else
  syft "$SCAN_TARGET" -o spdx-json > "$OUTPUT_DIR/${SCAN_NAME}-sbom-spdx.json"
fi
echo "[✓] Syft SPDX SBOM: $OUTPUT_DIR/${SCAN_NAME}-sbom-spdx.json"

# Generate Syft SBOM (CycloneDX format)
echo "[*] Generating Syft SBOM (CycloneDX)..."
if [ "$SCAN_TYPE" = "filesystem" ]; then
  syft "$SCAN_TARGET" -o cyclonedx > "$OUTPUT_DIR/${SCAN_NAME}-sbom-cyclonedx.json"
else
  syft "$SCAN_TARGET" -o cyclonedx > "$OUTPUT_DIR/${SCAN_NAME}-sbom-cyclonedx.json"
fi
echo "[✓] Syft CycloneDX SBOM: $OUTPUT_DIR/${SCAN_NAME}-sbom-cyclonedx.json"

# Generate vulnerability/security report
echo "[*] Generating vulnerability report..."
if [ "$SCAN_TYPE" = "filesystem" ]; then
  trivy fs --format json "$SCAN_TARGET" > "$OUTPUT_DIR/${SCAN_NAME}-trivy-report.json"
else
  trivy image --format json "$SCAN_TARGET" > "$OUTPUT_DIR/${SCAN_NAME}-trivy-report.json"
fi
echo "[✓] Trivy report: $OUTPUT_DIR/${SCAN_NAME}-trivy-report.json"

echo ""
echo "========================================"
echo "SBOM generation completed!"
echo "========================================"
ls -lah "$OUTPUT_DIR" | tail -n +2
