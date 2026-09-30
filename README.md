# CSE 141 Software Installer

Automated, isolated deployment of OSS CAD Suite (Yosys, NextPNR, GHDL) and the `just` task runner for UCSD CSE 141 on macOS. Requires only Homebrew.

## Installation

```bash
git clone [https://github.com/Retr0r0cket/cse141-software-installer.git](https://github.com/Retr0r0cket/cse141-software-installer.git)
cd cse141-software-installer
chmod +x install.sh
./install.sh

Just 'cse141-env' to start the env

Note on warnings: You may see red sandbox warnings (sandbox_operation.rb fix_linkage) during installation. These are expected for pre-compiled EDA binaries on macOS and do not affect functionality.