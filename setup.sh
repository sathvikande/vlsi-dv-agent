#!/bin/bash
# ==============================================================================
# Autonomous VLSI Design Verification (DV) Platform - One-Click Installer
# Author: Sathvik Ande (sathvikande007@gmail.com)
# Supports: macOS (Apple Silicon / Intel) and Ubuntu / Debian Linux
# ==============================================================================

set -e

CYAN='\033[1;36m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${CYAN}================================================================================${RESET}"
echo -e "${BOLD}⚡ AUTONOMOUS VLSI DV PLATFORM - INSTALLATION & SETUP${RESET}"
echo -e "${CYAN}================================================================================${RESET}"

OS="$(uname -s)"
echo -e "${YELLOW}Detected Operating System:${RESET} ${OS} ($(uname -m))"

# 1. Install Hardware Simulators and Formal Engines
if [ "$OS" = "Darwin" ]; then
    echo -e "\n${BOLD}[1/3] Installing EDA Simulators & Engines via Homebrew...${RESET}"
    if ! command -v brew >/dev/null 2>&1; then
        echo -e "${RED}Homebrew is required on macOS. Install from https://brew.sh/${RESET}"
        exit 1
    fi
    brew install verilator icarus-verilog yosys z3 python@3.14 || true
elif [ "$OS" = "Linux" ]; then
    echo -e "\n${BOLD}[1/3] Installing EDA Simulators & Engines via apt...${RESET}"
    sudo apt-get update
    sudo apt-get install -y verilator iverilog yosys z3 python3 python3-pip git make
fi

# 2. Install Python Dependencies
echo -e "\n${BOLD}[2/3] Installing Python DV Packages...${RESET}"
PYTHON_BIN="python3"
if command -v python3.14 >/dev/null 2>&1; then
    PYTHON_BIN="python3.14"
fi
echo -e "${YELLOW}Using Python binary:${RESET} $($PYTHON_BIN --version)"
$PYTHON_BIN -m pip install --upgrade pip
$PYTHON_BIN -m pip install -r requirements.txt

# 3. Setup Global CLI Link
echo -e "\n${BOLD}[3/3] Setting up 'vlsi' CLI runner...${RESET}"
INSTALL_DIR="$HOME/.local/bin"
mkdir -p "$INSTALL_DIR"
chmod +x ./vlsi
ln -sf "$(pwd)/vlsi" "$INSTALL_DIR/vlsi"

echo -e "\n${GREEN}✔ Installation completed successfully!${RESET}"
echo -e "${BOLD}To start using the tool, ensure ~/.local/bin is in your PATH:${RESET}"
echo -e "  ${CYAN}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
echo -e "\n${BOLD}Quick Test:${RESET}"
echo -e "  ${GREEN}vlsi sv${RESET}        # Run Pure SystemVerilog IEEE 1800 OOP Testbench"
echo -e "  ${GREEN}vlsi help${RESET}      # View full interactive command menu"
echo -e "  ${GREEN}vlsi run${RESET}       # Execute end-to-end verification demo suite"
echo -e "${CYAN}================================================================================${RESET}"
