#!/bin/bash

# TechResona Production Build Script
# This script creates an optimized production build ready for cPanel deployment

set -e  # Exit on error

echo "======================================"
echo "TechResona Production Build"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Clean previous builds
echo -e "${YELLOW}[1/6] Cleaning previous builds...${NC}"
rm -rf dist/
rm -rf production-build/
mkdir -p production-build

# Step 2: Install frontend dependencies
echo -e "${YELLOW}[2/6] Installing frontend dependencies...${NC}"
npm install

# Step 3: Build frontend
echo -e "${YELLOW}[3/6] Building Astro frontend...${NC}"
npm run build

echo -e "${GREEN}✓ Frontend build complete${NC}"
echo ""

# Step 4: Copy frontend files
echo -e "${YELLOW}[4/6] Copying frontend files to production-build/...${NC}"
cp -r dist/* production-build/
cp .htaccess production-build/
cp CPANEL_DEPLOYMENT_GUIDE.md production-build/

# Step 5: Copy backend files
echo -e "${YELLOW}[5/6] Copying backend files...${NC}"
mkdir -p production-build/api
cp -r backend/server.py production-build/api/
cp -r backend/requirements.txt production-build/api/

# Create .env template
cat > production-build/api/.env.example << 'EOF'
# MongoDB Configuration
MONGO_URL=mongodb://your-mongodb-atlas-connection-string

# Slack Webhook (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Application Settings
ENVIRONMENT=production
DEBUG=false
EOF

# Create passenger_wsgi.py for cPanel
cat > production-build/api/passenger_wsgi.py << 'EOF'
import sys
import os

# Add virtual environment to path
interpreter = os.path.join(os.getcwd(), 'venv', 'bin', 'python')
if sys.executable != interpreter:
    os.execl(interpreter, interpreter, *sys.argv)

# Add application directory to path
sys.path.insert(0, os.path.dirname(__file__))

# Import FastAPI app
from server import app as application
EOF

echo -e "${GREEN}✓ Backend files copied${NC}"
echo ""

# Step 6: Create deployment package
echo -e "${YELLOW}[6/6] Creating deployment package...${NC}"
cd production-build
tar -czf ../techresona-production.tar.gz .
cd ..

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}✓ Production Build Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo "Build location: ./production-build/"
echo "Deployment package: ./techresona-production.tar.gz"
echo ""
echo "Next steps:"
echo "1. Upload techresona-production.tar.gz to your cPanel server"
echo "2. Extract in public_html/ directory"
echo "3. Follow CPANEL_DEPLOYMENT_GUIDE.md for complete setup"
echo ""
echo "Build size:"
du -sh production-build/
du -sh techresona-production.tar.gz
echo ""
