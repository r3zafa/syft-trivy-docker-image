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
  echo "Usage: $0 [--help]"
  echo "Creates output directories for SBOM and severity scan."
}

if [ "$#" -gt 0 ]; then
  case "$1" in
    --help)
      show_help
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      print_warning "Usage: $0 [--help]"
      exit 1
      ;;
  esac
fi

mkdir -p /workspace/sbom /workspace/sbom/severity-scan
