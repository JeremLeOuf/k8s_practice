#!/bin/bash

set -e

echo "⚡ Installing uv - Fast Python package installer..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if uv is already installed
if command -v uv &> /dev/null; then
    echo -e "${GREEN}✓ uv is already installed${NC}"
    uv --version
    exit 0
fi

echo -e "${BLUE}Downloading and installing uv...${NC}"

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

# Add to PATH (for current session)
export PATH="$HOME/.cargo/bin:$PATH"

echo -e "${GREEN}✅ uv installed successfully!${NC}"
echo ""
echo "Add to your ~/.bashrc or ~/.zshrc:"
echo 'export PATH="$HOME/.cargo/bin:$PATH"'
echo ""
uv --version

