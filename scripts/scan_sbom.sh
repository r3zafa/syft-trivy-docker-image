#!/bin/sh
set -eu

# Color and bold logic (TTY/tput/ANSI fallback)
if [ -t 1 ]; then
  if command -v tput >/dev/null 2>&1; then
    YELLOW="$(tput setaf 3)"
    RED="$(tput setaf 1)"
    BOLD="$(tput bold)"
    NC="$(tput sgr0)"
  else
    YELLOW='\033[1;33m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
  fi
else
  YELLOW=''
  RED=''
  BOLD=''
  NC=''
fi

print_warning() { echo "${YELLOW}${BOLD}[!] $1${NC}"; }
print_error() { echo "${RED}${BOLD}[✗] $1${NC}"; }

show_help() {
  echo "Usage: $0 failOnSeverity=LEVEL"
  echo "  failOnSeverity=LEVEL  Severity level for trivy (required)"
  echo "  --help                Show this help"
}

failOnSeverity=""

if [ "$#" -eq 0 ]; then
  print_error "No arguments provided."
  print_warning "Usage: $0 failOnSeverity=LEVEL"
  print_warning "Try '$0 --help' for more information."
  exit 1
fi

for arg in "$@"; do
  case $arg in
    --help)
      show_help
      exit 0
      ;;
    failOnSeverity=*)
      failOnSeverity="${arg#*=}"
      ;;
    *)
      print_error "Unknown option: $arg"
      print_warning "Usage: $0 failOnSeverity=LEVEL"
      exit 1
      ;;
  esac
done

if [ -z "$failOnSeverity" ]; then
  print_error "failOnSeverity=LEVEL is required."
  print_warning "Usage: $0 failOnSeverity=LEVEL"
  exit 1
fi

SBOM=/workspace/sbom/spdx.json
if [ ! -f "$SBOM" ]; then SBOM=/workspace/sbom/cyclonedx.json; fi
mkdir -p /workspace/sbom/sevirity-scan
trivy sbom --ignore-unfixed --timeout 10m --severity "${failOnSeverity}" --format table "$SBOM" | tee /workspace/sbom/sevirity-scan/trivy-sbom.txt || true
trivy sbom --ignore-unfixed --timeout 10m --severity "${failOnSeverity}" --format sarif --output /workspace/sbom/sevirity-scan/trivy-sbom.sarif "$SBOM" || true
trivy sbom --ignore-unfixed --timeout 10m --severity "${failOnSeverity}" --exit-code 1 "$SBOM"
if [ $? -ne 0 ]; then
  echo "##vso[task.setvariable variable=hasFindings;isOutput=true]true"
else
	echo "##vso[task.setvariable variable=hasFindings;isOutput=true]false"
fi

# Ensure files are writable and owned by the current user (not root)
chmod -R u+rwX /workspace/sbom
chown -R "$(id -u):$(id -g)" /workspace/sbom || true
