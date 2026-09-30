#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$PATH"

INSTALL_DIR="${HOME}/.local/share/cse141-env"
BIN_DIR="${HOME}/.local/bin"
ARCH="$(uname -m)"
OS="$(uname -s)"

# Validate platform
if [[ "${OS}" != "Darwin" || "${ARCH}" != "arm64" ]]; then
    echo "Error: This installer is tailored for macOS Apple Silicon (arm64)." >&2
    exit 1
fi

echo "==> Creating install directories..."
mkdir -p "${INSTALL_DIR}" "${BIN_DIR}"

# 1. Download & extract OSS CAD Suite (Darwin arm64)
echo "==> Resolving latest OSS CAD Suite release..."
CAD_URL=$(curl -sL https://api.github.com/repos/YosysHQ/oss-cad-suite-build/releases/latest \
  | grep "browser_download_url.*darwin-arm64.*\.tgz\"" \
  | cut -d : -f 2,3 \
  | tr -d ' "')

CAD_TARBALL="/tmp/oss-cad-suite-darwin-arm64.tgz"

echo "==> Downloading OSS CAD Suite from ${CAD_URL}..."
curl -L --progress-bar "${CAD_URL}" -o "${CAD_TARBALL}"

echo "==> Extracting to ${INSTALL_DIR}..."
rm -rf "${INSTALL_DIR}/oss-cad-suite"
tar -xzf "${CAD_TARBALL}" -C "${INSTALL_DIR}"
rm -f "${CAD_TARBALL}"

# 2. Fetch standalone `just` binary
echo "==> Fetching standalone 'just' binary..."
JUST_URL=$(curl -sL https://api.github.com/repos/casey/just/releases/latest \
  | grep "browser_download_url.*aarch64-apple-darwin\.tar\.gz\"" \
  | cut -d : -f 2,3 \
  | tr -d ' "')

JUST_TARBALL="/tmp/just.tar.gz"
curl -L -s "${JUST_URL}" -o "${JUST_TARBALL}"

# Ensure destination directory exists before unpacking
mkdir -p "${INSTALL_DIR}/oss-cad-suite/bin"
tar -xzf "${JUST_TARBALL}" -C "${INSTALL_DIR}/oss-cad-suite/bin" just
rm -f "${JUST_TARBALL}"
chmod +x "${INSTALL_DIR}/oss-cad-suite/bin/just"

# 3. Clear quarantine flags
echo "==> Removing macOS Gatekeeper quarantine attributes..."
xattr -r -d com.apple.quarantine "${INSTALL_DIR}/oss-cad-suite" 2>/dev/null || true

# 4. Generate the isolated subshell launcher
echo "==> Generating 'cse141-env' launcher..."
cat << 'EOF' > "${BIN_DIR}/cse141-env"
#!/usr/bin/env bash
CAD_ROOT="${HOME}/.local/share/cse141-env/oss-cad-suite"

if [ ! -d "${CAD_ROOT}" ]; then
    echo "Error: CSE 141 environment not found at ${CAD_ROOT}" >&2
    exit 1
fi

TARGET_SHELL="${SHELL:-/bin/zsh}"
SHELL_NAME="$(basename "${TARGET_SHELL}")"

if [ "${SHELL_NAME}" = "fish" ]; then
    exec "${TARGET_SHELL}" -C "source '${CAD_ROOT}/environment.fish'; functions -c fish_prompt __orig_fish_prompt; function fish_prompt; echo -n '(cse141) '; __orig_fish_prompt; end"
else
    source "${CAD_ROOT}/environment"
    export PS1="(cse141) ${PS1:-\u@\h:\w\$ }"
    exec "${TARGET_SHELL}" -i
fi
EOF

chmod +x "${BIN_DIR}/cse141-env"

# 5. Automatically configure PATH for detected shells
echo "==> Configuring shell PATH..."

# 5a. Fish shell configuration
if command -v fish >/dev/null 2>&1; then
    echo "Configuring Fish shell..."
    fish -c "fish_add_path -U '${BIN_DIR}'" 2>/dev/null || true
fi

# 5b. Zsh configuration (~/.zshrc)
ZSHRC="${HOME}/.zshrc"
if [[ -f "${ZSHRC}" || "${SHELL:-}" == *"zsh"* ]]; then
    touch "${ZSHRC}"
    if ! grep -qs 'export PATH="\$HOME/.local/bin:\$PATH"' "${ZSHRC}" && ! grep -qs "export PATH=\"${BIN_DIR}:\$PATH\"" "${ZSHRC}"; then
        echo "Configuring Zsh (~/.zshrc)..."
        echo '' >> "${ZSHRC}"
        echo '# CSE 141 environment path' >> "${ZSHRC}"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${ZSHRC}"
    fi
fi

# 5c. Bash configuration (~/.bash_profile on macOS, ~/.bashrc on Linux)
BASH_PROFILE="${HOME}/.bash_profile"
BASHRC="${HOME}/.bashrc"
TARGET_BASH_FILE="${BASH_PROFILE}"

# On pure Linux systems without .bash_profile, use .bashrc
if [[ "${OS}" != "Darwin" && ! -f "${BASH_PROFILE}" && -f "${BASHRC}" ]]; then
    TARGET_BASH_FILE="${BASHRC}"
fi

if [[ -f "${TARGET_BASH_FILE}" || "${SHELL:-}" == *"bash"* ]]; then
    touch "${TARGET_BASH_FILE}"
    if ! grep -qs 'export PATH="\$HOME/.local/bin:\$PATH"' "${TARGET_BASH_FILE}" && ! grep -qs "export PATH=\"${BIN_DIR}:\$PATH\"" "${TARGET_BASH_FILE}"; then
        echo "Configuring Bash (${TARGET_BASH_FILE})..."
        echo '' >> "${TARGET_BASH_FILE}"
        echo '# CSE 141 environment path' >> "${TARGET_BASH_FILE}"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${TARGET_BASH_FILE}"
    fi
fi

echo ""
echo "Installation complete."
echo "Run 'cse141-env' to start the environment."