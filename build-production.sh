#!/bin/bash

# TechResona Production Build Script
# Optimized for deployment on aPanel with backend on port 9001

set -e  # Exit on error

echo "🚀 Starting TechResona Optimized Production Build..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check Node.js version
echo -e "${BLUE}📋 Checking Node.js version...${NC}"
node_version=$(node -v)
echo "   Node.js: $node_version"
echo ""

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf dist/
rm -rf production-build/
echo "   ✓ Cleaned"
echo ""

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}📦 Installing dependencies...${NC}"
  npm install
  echo "   ✓ Dependencies installed"
  echo ""
else
  echo -e "${GREEN}✓ Dependencies already installed${NC}"
  echo ""
fi

# Optimize images
echo -e "${BLUE}🎨 Optimizing images...${NC}"
node optimize-images.mjs
echo "   ✓ Images optimized"
echo ""

# Run Astro build
echo -e "${BLUE}🔨 Building Astro site...${NC}"
npm run build
echo "   ✓ Astro build complete"
echo ""

# Rename dist to production-build
echo -e "${BLUE}📦 Creating production package...${NC}"
mv dist production-build
echo "   ✓ Renamed dist/ to production-build/"
echo ""

# Copy backend files
echo -e "${BLUE}📋 Copying backend files...${NC}"
mkdir -p production-build/backend
cp backend/server.py production-build/backend/
cp backend/requirements.txt production-build/backend/
echo "   ✓ Backend files copied"
echo ""

# Copy deployment configs
echo -e "${BLUE}📝 Copying deployment configurations...${NC}"
cp nginx-production-9001.conf production-build/nginx-techresona.conf
cp supervisor-backend-9001.conf production-build/supervisor-backend.conf
echo "   ✓ Configuration files copied"
echo ""

# Create .env template
echo -e "${BLUE}📄 Creating .env template...${NC}"
cat > production-build/backend/.env.example << 'EOF'
# MongoDB Configuration (Optional)
MONGO_URL=

# Slack Webhook (Optional)
SLACK_WEBHOOK_URL=

# Email Configuration (Optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=
SMTP_PASSWORD=
SMTP_FROM_EMAIL=
SMTP_TO_EMAIL=info@techresona.com

# Application Settings
ENVIRONMENT=production
DEBUG=false
EOF
echo "   ✓ .env.example created"
echo ""

# Display build stats
echo -e "${GREEN}📊 Build Statistics:${NC}"
echo "   Production build size:"
du -sh production-build/ | awk '{print "   " $1}'
echo ""
echo "   Backend files:"
ls -lh production-build/backend/ | grep -E '\.(py|txt)$' | awk '{print "   " $9 " - " $5}'
echo ""

# Create deployment package
echo -e "${BLUE}📦 Creating deployment tarball...${NC}"
tar -czf techresona-production.tar.gz production-build/
tarball_size=$(du -sh techresona-production.tar.gz | awk '{print $1}')
echo "   ✓ Created: techresona-production.tar.gz ($tarball_size)"
echo ""

# Create README for deployment
cat > production-build/DEPLOYMENT_README.md << 'EOF'
# TechResona Production Deployment Guide

## 📦 Package Contents

```
production-build/
├── index.html              # Frontend entry point
├── _astro/                 # Optimized assets (CSS, JS, images)
├── images/                 # Optimized images (WebP, AVIF, PNG)
├── backend/                # FastAPI backend
│   ├── server.py
│   ├── requirements.txt
│   └── .env.example
├── nginx-techresona.conf   # Nginx configuration
└── supervisor-backend.conf # Supervisor configuration
```

## 🚀 Quick Deployment Steps

### 1. Upload Files

```bash
# Extract on server
tar -xzf techresona-production.tar.gz
cd production-build/
```

### 2. Setup Backend

```bash
# Navigate to backend
cd backend/

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env file (copy from .env.example and fill in values)
cp .env.example .env
nano .env
```

### 3. Configure Supervisor

```bash
# Copy supervisor config
sudo cp supervisor-backend.conf /etc/supervisor/conf.d/techresona-backend.conf

# Update paths in the config file
sudo nano /etc/supervisor/conf.d/techresona-backend.conf

# Update supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start techresona-backend
sudo supervisorctl status techresona-backend
```

### 4. Configure Nginx

```bash
# Copy nginx config
sudo cp nginx-techresona.conf /etc/nginx/sites-available/techresona.com

# Update the root path in nginx config
sudo nano /etc/nginx/sites-available/techresona.com

# Enable site
sudo ln -s /etc/nginx/sites-available/techresona.com /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### 5. Verify Deployment

```bash
# Check backend
curl http://localhost:9001/api/health

# Check frontend
curl https://techresona.com/

# Check API through nginx
curl https://techresona.com/api/health
```

## 🔧 Configuration Notes

### Backend Port
- Backend runs on **localhost:9001** (not exposed publicly)
- Nginx proxies `/api/*` requests to `http://127.0.0.1:9001`

### CORS Configuration
- Backend only accepts requests from: `https://techresona.com` and `https://www.techresona.com`
- Configured in `backend/server.py`

### Database (Optional)
- MongoDB is optional - backend works without it
- Enquiries will be logged to console if no database
- To enable: Add `MONGO_URL` to `.env` file

### Security Headers
- All security headers configured in Nginx
- HTTPS enforced (HTTP redirects to HTTPS)
- X-Frame-Options, CSP, and other headers included

## 📝 Environment Variables

Create `backend/.env` with these variables:

```env
# MongoDB (Optional)
MONGO_URL=mongodb+srv://user:pass@cluster.mongodb.net/techresona

# Email Notifications (Optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_EMAIL=noreply@techresona.com
SMTP_TO_EMAIL=info@techresona.com

# Slack Notifications (Optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Application
ENVIRONMENT=production
DEBUG=false
```

## ✅ Performance Optimizations Included

- ✅ Image optimization (WebP, AVIF formats)
- ✅ Critical CSS inlined
- ✅ HTML/CSS/JS compression
- ✅ Lazy loading for images
- ✅ Resource hints (preconnect, dns-prefetch)
- ✅ Browser caching strategy
- ✅ Gzip compression configured
- ✅ Security headers
- ✅ HTTPS enforcement

## 🆘 Troubleshooting

### Backend not starting
```bash
# Check logs
sudo tail -f /var/log/supervisor/techresona-backend.err.log

# Restart backend
sudo supervisorctl restart techresona-backend
```

### API returns 502
```bash
# Check if backend is running
sudo supervisorctl status techresona-backend
netstat -tlnp | grep 9001

# Check nginx configuration
sudo nginx -t
```

### Contact form not working
```bash
# Test API directly
curl -X POST http://localhost:9001/api/enquiries \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","phone":"1234567890","message":"Test"}'

# Check CORS headers
curl -I https://techresona.com/api/health
```

## 📞 Support

For issues, contact: support@techresona.com
EOF

echo -e "${GREEN}✅ Production build completed successfully!${NC}"
echo ""
echo -e "${BLUE}📦 Deployment Package Ready:${NC}"
echo "   📁 Directory: production-build/"
echo "   📦 Tarball: techresona-production.tar.gz ($tarball_size)"
echo ""
echo -e "${BLUE}🎯 Next Steps:${NC}"
echo "   1. Upload techresona-production.tar.gz to your server"
echo "   2. Extract and follow instructions in production-build/DEPLOYMENT_README.md"
echo "   3. Configure backend .env file"
echo "   4. Setup supervisor and nginx"
echo ""
echo -e "${YELLOW}⚠️  Important Reminders:${NC}"
echo "   • Backend runs on localhost:9001 (not exposed publicly)"
echo "   • Update paths in nginx and supervisor configs"
echo "   • Create .env file from .env.example"
echo "   • Ensure SSL certificates are configured"
echo ""
echo -e "${GREEN}🎉 Happy Deploying!${NC}"
