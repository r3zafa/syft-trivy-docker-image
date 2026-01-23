
#!/bin/sh
# test_script_options.sh - Test all .sh scripts for option parsing
set -eu




# Use tput for coloring and bold if available, fallback to ANSI, disable if not a TTY
if [ -t 1 ]; then
  if command -v tput >/dev/null 2>&1; then
    BLUE="$(tput setaf 4)"
    GREEN="$(tput setaf 2)"
    RED="$(tput setaf 1)"
    BOLD="$(tput bold)"
    NC="$(tput sgr0)"
  else
    BLUE='\033[0;34m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    BOLD='\033[1m'
    NC='\033[0m'
  fi
else
  BLUE=''
  GREEN=''
  RED=''
  BOLD=''
  NC=''
fi

fail=0

step() { echo "${BLUE}${BOLD}➤ $1${NC}"; }
pass() { echo "${GREEN}$1${NC}"; }
failmsg() { echo "${RED}$1${NC}" >&2; }


step "Testing fail_on_findings.sh --help"
echo "--- Output: fail_on_findings.sh --help ---"
./scripts/fail_on_findings.sh --help || true
echo "--- End Output ---"
if ! ./scripts/fail_on_findings.sh --help | grep -q Usage; then
  failmsg "fail_on_findings.sh --help failed"
  fail=1
fi
step "Testing fail_on_findings.sh error on unknown option"
echo "--- Output: fail_on_findings.sh --badopt ---"
./scripts/fail_on_findings.sh --badopt || true
echo "--- End Output ---"
if ./scripts/fail_on_findings.sh --badopt 2>&1 | grep -q '\[✗\] Unknown option:'; then
  pass "fail_on_findings.sh error test passed"
else
  failmsg "fail_on_findings.sh error test failed"
  fail=1
fi


step "Testing prepare_output_dirs.sh --help"
echo "--- Output: prepare_output_dirs.sh --help ---"
./scripts/prepare_output_dirs.sh --help || true
echo "--- End Output ---"
if ! ./scripts/prepare_output_dirs.sh --help | grep -q Usage; then
  failmsg "prepare_output_dirs.sh --help failed"
  fail=1
fi
step "Testing prepare_output_dirs.sh error on unknown option"
echo "--- Output: prepare_output_dirs.sh --badopt ---"
./scripts/prepare_output_dirs.sh --badopt || true
echo "--- End Output ---"
if ./scripts/prepare_output_dirs.sh --badopt 2>&1 | grep -q '\[✗\] Unknown option:'; then
  pass "prepare_output_dirs.sh error test passed"
else
  failmsg "prepare_output_dirs.sh error test failed"
  fail=1
fi


step "Testing generate_sboms.sh --help"
echo "--- Output: generate_sboms.sh --help ---"
./scripts/generate_sboms.sh --help || true
echo "--- End Output ---"
if ! ./scripts/generate_sboms.sh --help | grep -q Usage; then
  failmsg "generate_sboms.sh --help failed"
  fail=1
fi
step "Testing generate_sboms.sh error on missing workdir"
echo "--- Output: generate_sboms.sh (no args) ---"
./scripts/generate_sboms.sh || true
echo "--- End Output ---"
if ./scripts/generate_sboms.sh 2>&1 | grep -q '\[✗\] No arguments provided.'; then
  pass "generate_sboms.sh error test passed"
else
  failmsg "generate_sboms.sh error test failed"
  fail=1
fi


step "Testing scan_sbom.sh --help"
echo "--- Output: scan_sbom.sh --help ---"
./scripts/scan_sbom.sh --help || true
echo "--- End Output ---"
if ! ./scripts/scan_sbom.sh --help | grep -q Usage; then
  failmsg "scan_sbom.sh --help failed"
  fail=1
fi
step "Testing scan_sbom.sh error on missing failOnSeverity"
echo "--- Output: scan_sbom.sh (no args) ---"
./scripts/scan_sbom.sh || true
echo "--- End Output ---"
if ./scripts/scan_sbom.sh 2>&1 | grep -q '\[✗\] No arguments provided.'; then
  pass "scan_sbom.sh error test passed"
else
  failmsg "scan_sbom.sh error test failed"
  fail=1
fi


step "Testing verify_tools.sh --help"
echo "--- Output: verify_tools.sh --help ---"
./scripts/verify_tools.sh --help || true
echo "--- End Output ---"
if ! ./scripts/verify_tools.sh --help | grep -q Usage; then
  failmsg "verify_tools.sh --help failed"
  fail=1
fi
step "Testing verify_tools.sh error on unknown option"
echo "--- Output: verify_tools.sh --badopt ---"
./scripts/verify_tools.sh --badopt || true
echo "--- End Output ---"
if ./scripts/verify_tools.sh --badopt 2>&1 | grep -q '\[✗\] Unknown option:'; then
  pass "verify_tools.sh error test passed"
else
  failmsg "verify_tools.sh error test failed"
  fail=1
fi


step "Testing deduplicate_sbom.sh --help"
echo "--- Output: deduplicate_sbom.sh --help ---"
./scripts/deduplicate_sbom.sh --help || true
echo "--- End Output ---"
if ! ./scripts/deduplicate_sbom.sh --help | grep -q Usage; then
  failmsg "deduplicate_sbom.sh --help failed"
  fail=1
fi
step "Testing deduplicate_sbom.sh error on unknown option"
echo "--- Output: deduplicate_sbom.sh --badopt ---"
./scripts/deduplicate_sbom.sh --badopt || true
echo "--- End Output ---"
if ./scripts/deduplicate_sbom.sh --badopt 2>&1 | grep -q '\[✗\] Unknown option:'; then
  pass "deduplicate_sbom.sh error test passed"
else
  failmsg "deduplicate_sbom.sh error test failed"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  pass "All script option tests passed."
else
  failmsg "Some script option tests failed."
  exit 1
fi
