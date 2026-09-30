# CSE 141 Software Installer

Automated, isolated deployment of OSS CAD Suite (Yosys, NextPNR, GHDL) and the `just` task runner for UCSD CSE 141 on macOS Apple Silicon.

## Installation

Clone the repository:

```bash
git clone [https://github.com/Retr0r0cket/cse141-software-installer.git](https://github.com/Retr0r0cket/cse141-software-installer.git)
cd cse141-software-installer
```

### Option 1: Standalone Install (Recommended — No Homebrew Required)

Installs directly into `~/.local/share/cse141-env` and symlinks the runner into `~/.local/bin`:

```bash
chmod install-standalone.sh
./install-standalone.sh
```

Ensure `~/.local/bin` is in your `PATH`:
```bash
export PATH="$HOME/.local/bin:$PATH"
```

### Option 2: Homebrew Formula

Installs isolated via a local tap formula:

```bash
chmod install.sh
./install.sh
```

> **Note on warnings:** You may see red sandbox warnings (`sandbox_operation.rb fix_linkage`) during a Homebrew installation. These are expected for pre-compiled EDA binaries on macOS and do not affect functionality.

---

## Usage

Start the isolated subshell environment:

```bash
cse141-env
```

To verify active tools within the subshell:

```bash
which yosys nextpnr-ice40 ghdl just
```

Exit the subshell when finished:

```bash
exit
```

---

## Uninstallation

To remove the standalone setup:

```bash
chmod uninstall-standalone.sh
./uninstall-standalone.sh
```

To remove the Homebrew setup:

```bash
brew uninstall oss-cad-suite
rm -f /opt/homebrew/bin/cse141-env
```