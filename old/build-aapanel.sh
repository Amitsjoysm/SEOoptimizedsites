#!/bin/bash

# TechResona Production Build Script for aPanel
# This script creates an optimized production build ready for aPanel deployment

set -e  # Exit on error

echo "======================================"
echo "TechResona Production Build (aPanel)"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Step 1: Clean previous builds
echo -e "${YELLOW}[1/7] Cleaning previous builds...${NC}"
rm -rf dist/
rm -rf production-build/
rm -rf techresona-production.tar.gz
mkdir -p production-build

# Step 2: Install frontend dependencies
echo -e "${YELLOW}[2/7] Installing frontend dependencies...${NC}"
npm install --production=false

# Step 3: Build frontend
echo -e "${YELLOW}[3/7] Building Astro frontend...${NC}"
npm run build

echo -e "${GREEN}✓ Frontend build complete${NC}"
echo ""

# Step 4: Copy frontend files
echo -e "${YELLOW}[4/7] Copying frontend files to production-build/...${NC}"
cp -r dist/* production-build/

# Copy deployment guides
cp AAPANEL_DEPLOYMENT_GUIDE.md production-build/

# Step 5: Copy backend files
echo -e "${YELLOW}[5/7] Copying backend files...${NC}"
mkdir -p production-build/backend
cp backend/server.py production-build/backend/
cp backend/requirements.txt production-build/backend/

# Create .env template
cat > production-build/backend/.env.example << 'EOF'
# MongoDB Configuration
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/techresona?retryWrites=true&w=majority

# Slack Webhook (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Application Settings
ENVIRONMENT=production
DEBUG=false
EOF

echo -e "${GREEN}✓ Backend files copied${NC}"
echo ""

# Step 6: Create Nginx configuration template
echo -e "${YELLOW}[6/7] Creating Nginx configuration template...${NC}"
cat > production-build/nginx-techresona.conf << 'EOF'
server {
    listen 80;
    listen [::]:80;
    server_name techresona.com www.techresona.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name techresona.com www.techresona.com;

    ssl_certificate /etc/letsencrypt/live/techresona.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/techresona.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    root /home/username/public_html;
    index index.html;

    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css text/javascript application/javascript application/json;

    location /api/ {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location / {
        try_files $uri $uri/ $uri.html /index.html;
    }
}
EOF

# Step 7: Create deployment package
echo -e "${YELLOW}[7/7] Creating deployment package...${NC}"
cd production-build
tar -czf ../techresona-aapanel.tar.gz .
cd ..

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}✓ Production Build Complete!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${BLUE}Build Details:${NC}"
echo "  Build location: ./production-build/"
echo "  Deployment package: ./techresona-aapanel.tar.gz"
echo ""
echo -e "${BLUE}Package Contents:${NC}"
echo "  ✓ Frontend static files (Astro build)"
echo "  ✓ Backend API (FastAPI)"
echo "  ✓ Nginx configuration template"
echo "  ✓ Environment configuration examples"
echo "  ✓ Complete deployment guide"
echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "  1. Upload techresona-aapanel.tar.gz to your aPanel server"
echo "  2. Extract in public_html/ directory"
echo "  3. Follow AAPANEL_DEPLOYMENT_GUIDE.md for setup"
echo "  4. Configure MongoDB connection in backend/.env"
echo "  5. Setup Nginx configuration"
echo "  6. Start backend service with supervisor or PM2"
echo ""
echo -e "${BLUE}Build Size:${NC}"
du -sh production-build/ 2>/dev/null || echo "  Build directory size: N/A"
du -sh techresona-aapanel.tar.gz 2>/dev/null || echo "  Package size: N/A"
echo ""
echo -e "${GREEN}Ready for aPanel deployment! 🚀${NC}"
echo ""
