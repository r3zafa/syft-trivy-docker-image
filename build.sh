#!/bin/bash

# Build the Docker image for Syft and Trivy SBOM generation
# This script builds a reusable image that can be used with any project

set -e

IMAGE_TAG="${1:-syft-trivy-sbom:latest}"

echo "Building Docker image: $IMAGE_TAG"
docker build -t "$IMAGE_TAG" .

echo ""
echo "✅ Image built successfully: $IMAGE_TAG"
echo ""
echo "📋 Usage Options:"
echo ""
echo "1️⃣  Build and scan with environment variables:"
echo "   export PROJECT_NAME=my-project"
echo "   export PROJECT_PATH=/path/to/my/project"
echo "   export OUTPUT_DIR=./sbom-output"
echo "   docker-compose up"
echo ""
echo "2️⃣  Interactive shell:"
echo "   PROJECT_PATH=/path/to/project docker-compose run --rm sbom-generator /bin/bash"
echo ""
echo "3️⃣  Generate SBOM directly:"
echo "   docker run -it --rm \\"
echo "     -v /path/to/project:/project \\"
echo "     -v ./sbom-output:/sbom-output \\"
echo "     $IMAGE_TAG \\"
echo "     syft /project -o json > sbom-output/sbom.json"
echo ""
echo "4️⃣  Scan with Trivy:"
echo "   docker run -it --rm \\"
echo "     -v /path/to/project:/project \\"
echo "     -v ./sbom-output:/sbom-output \\"
echo "     $IMAGE_TAG \\"
echo "     trivy fs /project --format json > sbom-output/vulnerabilities.json"
