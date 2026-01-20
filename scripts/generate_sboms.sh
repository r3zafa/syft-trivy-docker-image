#!/bin/sh
set -euxo pipefail
syft "dir:${workdir}" -o spdx-json > out/sbom/spdx.json
syft "dir:${workdir}" -o cyclonedx-json > out/sbom/cyclonedx.json
echo "Package=${packageName}" > out/sbom/metadata.txt
echo "Version=${packageVersion}" >> out/sbom/metadata.txt
echo "Supplier=${supplier}" >> out/sbom/metadata.txt
echo "GeneratedAt=$(date -u +%Y-%m-%dT%H-%M-%SZ)" >> out/sbom/metadata.txt
cd out/sbom && for f in *.json; do sha256sum "$f" > "$f.sha256"; done
