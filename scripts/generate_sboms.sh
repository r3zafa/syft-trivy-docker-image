


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
	echo "Usage: $0 workdir=DIR [key=value ...]"
	echo "  workdir=DIR         Directory to scan (required)"
	echo "  packageName=NAME    Package name (optional)"
	echo "  packageVersion=VER  Package version (optional)"
	echo "  supplier=SUPPLIER   Supplier name (optional)"
	echo "  --help              Show this help"
}

# Parse args
workdir=""
packageName=""
packageVersion=""
supplier=""

if [ "$#" -eq 0 ]; then
	print_error "No arguments provided."
	print_warning "Usage: $0 workdir=DIR [key=value ...]"
	print_warning "Try '$0 --help' for more information."
	exit 1
fi

for arg in "$@"; do
	case $arg in
		--help)
			show_help
			exit 0
			;;
		workdir=*)
			workdir="${arg#*=}"
			;;
		packageName=*)
			packageName="${arg#*=}"
			;;
		packageVersion=*)
			packageVersion="${arg#*=}"
			;;
		supplier=*)
			supplier="${arg#*=}"
			;;
		*)
			print_error "Unknown option: $arg"
			print_warning "Usage: $0 workdir=DIR [key=value ...]"
			exit 1
			;;
	esac
done

if [ -z "$workdir" ]; then
	print_error "workdir=DIR is required."
	print_warning "Usage: $0 workdir=DIR [key=value ...]"
	exit 1
fi

if [ -z "$workdir" ]; then
	print_error "workdir is required."
	print_warning "Usage: $0 [--help] workdir=DIR [key=value ...]"
	exit 1
fi

syft "dir:${workdir}" -o spdx-json > out/sbom/spdx.json
syft "dir:${workdir}" -o cyclonedx-json > out/sbom/cyclonedx.json
echo "Package=${packageName}" > out/sbom/metadata.txt
echo "Version=${packageVersion}" >> out/sbom/metadata.txt
echo "Supplier=${supplier}" >> out/sbom/metadata.txt
echo "GeneratedAt=$(date -u +%Y-%m-%dT%H-%M-%SZ)" >> out/sbom/metadata.txt
cd out/sbom && for f in *.json; do sha256sum "$f" > "$f.sha256"; done
