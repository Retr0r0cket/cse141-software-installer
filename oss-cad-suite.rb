class OssCadSuite < Formula
  desc "Digital design & FPGA toolchain suite (OSS CAD Suite + Just)"
  homepage "https://github.com/YosysHQ/oss-cad-suite-build"
  version "2026-06-14"

  # Enforce strict keg isolation: binaries will NOT link to /opt/homebrew/bin
  keg_only "this suite bundles conflicting compilers and python runtimes that pollute PATH"

  if Hardware::CPU.arm?
    url "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-06-14/oss-cad-suite-darwin-arm64-20260614.tgz"
    sha256 "29595c991ce1fdf5d207ecd45d37367686a0ac8c7ba6ee79a25bc3d34958ffcf"

    resource "just" do
      url "https://github.com/casey/just/releases/download/1.35.0/just-1.35.0-aarch64-apple-darwin.tar.gz"
      sha256 "898cc0623112a5912ef2dd891020d68e6b8eba9250c76460547f1703e550fabb"
    end
  else
    url "https://github.com/YosysHQ/oss-cad-suite-build/releases/download/2026-06-14/oss-cad-suite-darwin-x64-20260614.tgz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"

    resource "just" do
      url "https://github.com/casey/just/releases/download/1.35.0/just-1.35.0-x86_64-apple-darwin.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  def install
    # Strip macOS quarantine attributes if present
    system "xattr", "-dr", "com.apple.quarantine", "." rescue nil

    # Install the full unpacked tree into Homebrew's opt prefix
    prefix.install Dir["*"]

    # Unpack embedded 'just' directly into the keg's bin directory
    resource("just").stage do
      (bin/"just").install "just"
    end
  end

  def caveats
    <<~EOS
      Keg-only installation complete. Launch the isolated subshell with:
        cse141-env
    EOS
  end
end