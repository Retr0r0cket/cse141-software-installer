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