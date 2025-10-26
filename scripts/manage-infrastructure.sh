#!/bin/bash

set -e

echo "🎛️ Infrastructure Management Helper"
echo "==================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

show_menu() {
  echo -e "${BLUE}Choose an operation:${NC}"
  echo ""
  echo "  1) 📊 List current infrastructure"
  echo "  2) 📋 Validate Terraform configuration"
  echo "  3) 🚀 Deploy infrastructure (local)"
  echo "  4) 🗑️  Destroy infrastructure (local)"
  echo "  5) 🔍 Check for orphaned resources"
  echo "  6) 🧹 Clean up orphaned resources"
  echo "  7) 📥 Import existing resources"
  echo "  8) 🔄 Trigger GitHub Actions (instructions)"
  echo "  9) 📈 View CloudFront status"
  echo "  0) Exit"
  echo ""
  read -p "Enter choice [0-9]: " choice
}

case_1() {
  echo -e "${GREEN}📊 Listing current infrastructure...${NC}"
  ./scripts/list-all-aws-resources.sh
}

case_2() {
  echo -e "${GREEN}📋 Validating Terraform configuration...${NC}"
  cd infrastructure
  terraform init
  terraform validate
  terraform plan
  cd ..
}

case_3() {
  echo -e "${YELLOW}⚠️  Deploying infrastructure locally...${NC}"
  read -p "Continue? (yes/no): " confirm
  if [ "$confirm" = "yes" ]; then
    cd infrastructure
    terraform apply -auto-approve
    cd ..
  else
    echo "Cancelled"
  fi
}

case_4() {
  echo -e "${RED}🗑️  Destroying infrastructure locally...${NC}"
  echo "⚠️  This will destroy ALL resources!"
  read -p "Type 'yes' to confirm: " confirm
  if [ "$confirm" = "yes" ]; then
    cd infrastructure
    terraform destroy -auto-approve
    cd ..
  else
    echo "Cancelled"
  fi
}

case_5() {
  echo -e "${GREEN}🔍 Checking for orphaned resources...${NC}"
  ./scripts/check-aws-resources.sh
  echo ""
  echo -e "${YELLOW}Check the output above for resources not in Terraform state${NC}"
}

case_6() {
  echo -e "${YELLOW}🧹 Cleaning up orphaned resources...${NC}"
  echo "⚠️  This will delete orphaned AWS resources!"
  read -p "Continue? (yes/no): " confirm
  if [ "$confirm" = "yes" ]; then
    ./scripts/cleanup-orphaned-resources.sh
  else
    echo "Cancelled"
  fi
}

case_7() {
  echo -e "${GREEN}📥 Importing existing resources...${NC}"
  ./scripts/import-all-existing.sh
}

case_8() {
  echo -e "${BLUE}🔄 GitHub Actions Management${NC}"
  echo ""
  echo "To trigger GitHub Actions:"
  echo ""
  echo "1. Deploy via GitHub:"
  echo "   - Push to main: git push origin main"
  echo "   - OR go to: https://github.com/YOUR_USERNAME/REPO/actions"
  echo "   - Click 'Run workflow' → Select 'deploy'"
  echo ""
  echo "2. Destroy via GitHub:"
  echo "   - Go to: https://github.com/YOUR_USERNAME/REPO/actions"
  echo "   - Click 'Run workflow' → Select 'destroy'"
  echo ""
  echo "3. View workflow logs:"
  echo "   - Visit: https://github.com/YOUR_USERNAME/REPO/actions"
  echo ""
  read -p "Press Enter to continue..."
}

case_9() {
  echo -e "${GREEN}📈 CloudFront Status${NC}"
  echo ""
  aws cloudfront list-distributions \
    --query 'DistributionList.Items[*].[Id,Comment,Status,Enabled,DomainName]' \
    --output table 2>/dev/null || echo "No CloudFront distributions"
  
  echo ""
  echo "Note: CloudFront deployments take 15-20 minutes"
}

while true; do
  show_menu
  case $choice in
    1) case_1 ;;
    2) case_2 ;;
    3) case_3 ;;
    4) case_4 ;;
    5) case_5 ;;
    6) case_6 ;;
    7) case_7 ;;
    8) case_8 ;;
    9) case_9 ;;
    0) echo "👋 Goodbye!"; exit 0 ;;
    *) echo -e "${RED}Invalid option${NC}" ;;
  esac
  echo ""
  read -p "Press Enter to continue..."
done

