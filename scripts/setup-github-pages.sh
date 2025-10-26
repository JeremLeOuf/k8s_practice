#!/bin/bash

set -e

echo "🚀 Setting up GitHub Pages deployment..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📝 GitHub Pages setup instructions:${NC}"
echo ""
echo "1. Go to your GitHub repository"
echo "2. Click 'Settings' → 'Pages'"
echo "3. Under 'Source', select 'Deploy from a branch'"
echo "4. Choose branch: 'main' or 'fast_deploy'"
echo "5. Select folder: '/' (root)"
echo "6. Click 'Save'"
echo ""
echo -e "${GREEN}✅ GitHub Actions workflow is already configured${NC}"
echo ""
echo "Your site will be live at:"
echo -e "${YELLOW}https://JeremLeOuf.github.io/k8s_practice/${NC}"
echo ""
echo -e "${BLUE}After enabling GitHub Pages, push to trigger deployment:${NC}"
echo "git add ."
echo "git commit -m 'Setup GitHub Pages'"
echo "git push"
echo ""
echo -e "${GREEN}Done! Your frontend will deploy to GitHub Pages automatically.${NC}"

