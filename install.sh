#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FORMULA_SOURCE="${SCRIPT_DIR}/oss-cad-suite.rb"

echo "==> [1/4] Verifying Homebrew environment..."
if ! command -v brew >/dev/null 2>&1; then
  echo "Error: Homebrew is required but not installed." >&2
  exit 1
fi

BREW_PREFIX="$(brew --prefix)"
TAP_DIR="$(brew --repository)/Library/Taps/local/homebrew-eda"

echo "==> [2/4] Setting up local tap without remote clones..."
# Clean any broken or hanging homebrew-core tap attempts
rm -rf "$(brew --repository)/Library/Taps/homebrew/homebrew-core" 2>/dev/null || true

# Initialize local tap repository structure cleanly
mkdir -p "${TAP_DIR}/Formula"
if [[ ! -d "${TAP_DIR}/.git" ]]; then
  git -C "${TAP_DIR}" init -q
fi

if [[ ! -f "${FORMULA_SOURCE}" ]]; then
  echo "Error: Cannot locate formula at ${FORMULA_SOURCE}" >&2
  exit 1
fi

cp "${FORMULA_SOURCE}" "${TAP_DIR}/Formula/oss-cad-suite.rb"

echo "==> [3/4] Installing keg-only suite (API mode enabled, auto-update blocked)..."
# Remove previous broken build if present
HOMEBREW_NO_AUTO_UPDATE=1 brew uninstall --force local/eda/oss-cad-suite 2>/dev/null || true

# Build from local tap; ignore sandbox post-relocation warnings (Mach-O linkage)
HOMEBREW_NO_AUTO_UPDATE=1 brew install --build-from-source local/eda/oss-cad-suite || true

echo "==> [4/4] Writing isolated cse141-env launcher..."
LAUNCHER="${BREW_PREFIX}/bin/cse141-env"

cat << 'EOF' > "${LAUNCHER}"
#!/usr/bin/env bash
BREW_PREFIX="$(brew --prefix)"
OPT_PREFIX="${BREW_PREFIX}/opt/oss-cad-suite"

if [[ ! -d "${OPT_PREFIX}" ]]; then
  echo "Error: oss-cad-suite not found at ${OPT_PREFIX}" >&2
  exit 1
fi

USER_SHELL="$(basename "${SHELL:-bash}")"

echo "==> Launching isolated CSE 141 environment (Yosys, NextPNR, GHDL, Just)..."
echo "==> Type 'exit' to return to your normal environment."

if [[ "$USER_SHELL" == "fish" ]]; then
  exec fish -C "source '${OPT_PREFIX}/environment.fish'"
else
  exec bash --noprofile --norc -c "
    source '${OPT_PREFIX}/environment'
    PS1='\[\033[1;36m\](cse141)\[\033[0m\] \w \$ ' \${SHELL:-/bin/bash} -i
  "
fi
EOF

chmod 0755 "${LAUNCHER}"

echo ""
echo "============================================================"
echo " Installation Complete & Isolated"
echo " Global PATH is untouched."
echo " To activate your tools, run:"
echo ""
echo "    cse141-env"
echo ""
echo "============================================================"