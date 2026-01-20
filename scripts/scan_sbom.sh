#!/bin/sh
set -euo pipefail
SBOM=out/sbom/spdx.json
if [ ! -f "$SBOM" ]; then SBOM=out/sbom/cyclonedx.json; fi
mkdir -p out/sbom/sevirity-scan
trivy sbom --ignore-unfixed --timeout 10m --severity "${failOnSeverity}" --format table "$SBOM" | tee out/sbom/sevirity-scan/trivy-sbom.txt || true
trivy sbom --ignore-unfixed --timeout 10m --severity "${failOnSeverity}" --format sarif --output out/sbom/sevirity-scan/trivy-sbom.sarif "$SBOM" || true
trivy sbom --ignore-unfixed --timeout 10m --severity "${failOnSeverity}" --exit-code 1 "$SBOM"
if [ $? -ne 0 ]; then
  echo "##vso[task.setvariable variable=hasFindings;isOutput=true]true"
else
  echo "##vso[task.setvariable variable=hasFindings;isOutput=true]false"
fi
