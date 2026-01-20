#!/bin/sh
set -euxo pipefail
SBOM=out/sbom/spdx.json
if [ -f "$SBOM" ]; then
  jq '
    .packages |= map(
      if .externalRefs then
        .externalRefs |= unique_by(.referenceCategory, .referenceType, .referenceLocator)
      else
        .
      end
    )
  ' "$SBOM" > "$SBOM.tmp" && mv "$SBOM.tmp" "$SBOM"
fi
