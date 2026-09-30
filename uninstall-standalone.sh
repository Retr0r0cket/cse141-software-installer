#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${HOME}/.local/share/cse141-env"
LAUNCHER="${HOME}/.local/bin/cse141-env"

echo "==> Removing CSE 141 standalone environment..."

# 1. Remove CAD suite binaries and bundled just
if [ -d "${INSTALL_DIR}" ]; then
    rm -rf "${INSTALL_DIR}"
    echo "Removed: ${INSTALL_DIR}"
else
    echo "Directory not found (already removed): ${INSTALL_DIR}"
fi

# 2. Remove launcher wrapper
if [ -f "${LAUNCHER}" ]; then
    rm -f "${LAUNCHER}"
    echo "Removed: ${LAUNCHER}"
else
    echo "Launcher not found (already removed): ${LAUNCHER}"
fi

# 3. Clean up any leftover temporary archives
rm -f /tmp/oss-cad-suite* /tmp/just*

# 4. Clean ~/.zshrc if present
ZSHRC="${HOME}/.zshrc"
if [ -f "${ZSHRC}" ]; then
    echo "==> Cleaning PATH entries from ~/.zshrc..."
    sed -i '' '/# CSE 141 environment path/d' "${ZSHRC}" 2>/dev/null || true
    sed -i '' '\|export PATH="\$HOME/\.local/bin:\$PATH"|d' "${ZSHRC}" 2>/dev/null || true
fi

# 5. Clean Bash configuration entries if present
for BASH_FILE in "${HOME}/.bash_profile" "${HOME}/.bashrc"; do
    if [ -f "${BASH_FILE}" ]; then
        echo "==> Cleaning PATH entries from ${BASH_FILE}..."
        sed -i '' '/# CSE 141 environment path/d' "${BASH_FILE}" 2>/dev/null || true
        sed -i '' '\|export PATH="\$HOME/\.local/bin:\$PATH"|d' "${BASH_FILE}" 2>/dev/null || true
    fi
done

# 6. Remove from fish universal path if fish is present
if command -v fish >/dev/null 2>&1; then
    echo "==> Removing from Fish universal path..."
    fish -c "set -U fish_user_paths (string match -v '${HOME}/.local/bin' \$fish_user_paths)" 2>/dev/null || true
fi

# 7. Clean parent dir if empty
rmdir "${HOME}/.local/share" 2>/dev/null || true

echo "==> Standalone uninstallation complete."