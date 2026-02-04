#!/bin/bash

# TechResona Optimized Production Build for aaPanel
# Backend configured for localhost:9001

set -e  # Exit on error

echo "🚀 Starting TechResona aaPanel Production Build..."
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Check Node.js version
echo -e "${BLUE}📋 Checking environment...${NC}"
node_version=$(node -v)
echo "   Node.js: $node_version"
python_version=$(python3 --version 2>&1)
echo "   Python: $python_version"
echo ""

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
rm -rf dist/
rm -rf production-build/
rm -f techresona-aapanel.tar.gz
echo "   ✓ Cleaned"
echo ""

# Install/verify dependencies
if [ ! -d "node_modules" ]; then
  echo -e "${YELLOW}📦 Installing frontend dependencies...${NC}"
  npm install
  echo "   ✓ Frontend dependencies installed"
  echo ""
else
  echo -e "${GREEN}✓ Frontend dependencies already installed${NC}"
  echo ""
fi

# Build the site
echo -e "${BLUE}🔨 Building optimized Astro site...${NC}"
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

# Copy nginx configuration
echo -e "${BLUE}📝 Copying nginx configuration...${NC}"
cp nginx-production-9001.conf production-build/nginx-techresona.conf
echo "   ✓ Nginx config copied"
echo ""

# Copy supervisor configuration
echo -e "${BLUE}📝 Copying supervisor configuration...${NC}"
cp supervisor-backend-9001.conf production-build/supervisor-backend.conf
echo "   ✓ Supervisor config copied"
echo ""

# Create .env template
echo -e "${BLUE}📄 Creating .env template...${NC}"
cat > production-build/backend/.env.example << 'EOF'
# MongoDB Configuration (Optional - backend works without it)
MONGO_URL=

# Slack Webhook (Optional - for notifications)
SLACK_WEBHOOK_URL=

# Email Configuration (Optional - for notifications)
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

# Create comprehensive deployment guide
cat > production-build/AAPANEL_DEPLOYMENT_GUIDE.md << 'EOF'
# 🚀 TechResona - aaPanel Deployment Guide

## 📦 What's Included

```
production-build/
├── index.html                    # Main entry point
├── _astro/                       # Optimized CSS, JS, images
├── images/                       # Logo and images (WebP optimized)
├── favicons/                     # All favicon sizes
├── backend/
│   ├── server.py                # FastAPI backend
│   ├── requirements.txt         # Python dependencies
│   └── .env.example             # Environment template
├── nginx-techresona.conf        # Nginx configuration
├── supervisor-backend.conf      # Supervisor configuration
└── AAPANEL_DEPLOYMENT_GUIDE.md  # This file
```

## 🎯 Quick Start (5 Minutes)

### Step 1: Upload & Extract

```bash
# Upload techresona-aapanel.tar.gz to your server
# Extract in your web directory (e.g., /www/wwwroot/techresona.com/)
cd /www/wwwroot/techresona.com/
tar -xzf techresona-aapanel.tar.gz
cd production-build/
```

### Step 2: Setup Backend

```bash
# Navigate to backend directory
cd backend/

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install -r requirements.txt

# Create .env file
cp .env.example .env

# IMPORTANT: Edit .env if you want email/Slack notifications
# Backend works WITHOUT database - enquiries will be logged
nano .env
```

### Step 3: Configure Supervisor

```bash
# Copy supervisor config
sudo cp ../supervisor-backend.conf /etc/supervisor/conf.d/techresona-backend.conf

# Edit the config and update these paths:
# - command: /www/wwwroot/techresona.com/production-build/backend/venv/bin/uvicorn
# - directory: /www/wwwroot/techresona.com/production-build/backend
# - environment: PATH="/www/wwwroot/techresona.com/production-build/backend/venv/bin"
sudo nano /etc/supervisor/conf.d/techresona-backend.conf

# Reload supervisor
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start techresona-backend

# Check status
sudo supervisorctl status techresona-backend
```

### Step 4: Configure Nginx

```bash
# Go back to production-build directory
cd /www/wwwroot/techresona.com/production-build/

# Copy nginx config
sudo cp nginx-techresona.conf /etc/nginx/sites-available/techresona.com

# Edit nginx config and update:
# - root /www/wwwroot/techresona.com/production-build;
sudo nano /etc/nginx/sites-available/techresona.com

# Enable site (if using sites-available/sites-enabled pattern)
sudo ln -s /etc/nginx/sites-available/techresona.com /etc/nginx/sites-enabled/

# Test nginx configuration
sudo nginx -t

# Reload nginx
sudo systemctl reload nginx
```

### Step 5: Verify Everything Works

```bash
# Check backend is running
curl http://localhost:9001/api/health

# Should return:
# {"status":"healthy","database":"not_configured","slack_configured":false,"email_configured":false}

# Check frontend (replace with your domain)
curl https://techresona.com/

# Test contact form API
curl -X POST http://localhost:9001/api/enquiries \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "1234567890",
    "message": "This is a test message"
  }'
```

## ⚙️ Configuration Details

### Backend on localhost:9001

- Backend runs ONLY on `localhost:9001` (not publicly accessible)
- Nginx proxies `/api/*` requests to `http://127.0.0.1:9001`
- Frontend connects to backend via `http://localhost:9001/api/enquiries`

### Frontend Contact Form

- Located at: `https://techresona.com/contact/`
- Form submits to: `http://localhost:9001/api/enquiries`
- Success: Shows green message and resets form
- Error: Shows red message with details

### CORS Configuration

Backend accepts requests from:
- `https://techresona.com`
- `https://www.techresona.com`
- `http://localhost:4321` (for local development)

Configured in `backend/server.py` lines 20-25

### Database (Optional)

- MongoDB is **OPTIONAL**
- Backend works WITHOUT database
- Enquiries are logged to supervisor logs: `/var/log/supervisor/techresona-backend.out.log`
- To enable MongoDB: Add `MONGO_URL` to `.env`

### Email Notifications (Optional)

To receive email notifications for new enquiries:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
SMTP_FROM_EMAIL=noreply@techresona.com
SMTP_TO_EMAIL=info@techresona.com
```

**For Gmail:** Use App Password, not regular password
1. Enable 2FA on Gmail
2. Generate App Password: https://myaccount.google.com/apppasswords
3. Use that password in `.env`

### Slack Notifications (Optional)

To receive Slack notifications:

```env
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

Create webhook: https://api.slack.com/messaging/webhooks

## 🔧 aaPanel Specific Setup

### If Using aaPanel Web Interface:

1. **Create Website:**
   - Website > Add Site
   - Domain: `techresona.com`
   - Root: `/www/wwwroot/techresona.com/production-build`
   - PHP: Not needed (pure HTML/JS frontend)

2. **SSL Certificate:**
   - Website > Settings > SSL
   - Use Let's Encrypt (free)
   - Enable "Force HTTPS"

3. **Nginx Configuration:**
   - Website > Settings > Config
   - Replace entire config with contents of `nginx-techresona.conf`
   - Update the `root` path to match your installation

4. **Supervisor:**
   - App Store > Supervisor
   - Add new process:
     - Name: `techresona-backend`
     - Directory: `/www/wwwroot/techresona.com/production-build/backend`
     - Command: `/www/wwwroot/techresona.com/production-build/backend/venv/bin/uvicorn server:app --host 127.0.0.1 --port 9001 --workers 2`
     - User: `www` (or your web user)
     - Autostart: Yes
     - Autorestart: Yes

## 🐛 Troubleshooting

### Backend Won't Start

```bash
# Check logs
sudo tail -f /var/log/supervisor/techresona-backend.err.log

# Common issues:
# 1. Wrong path in supervisor config
# 2. Virtual environment not activated
# 3. Missing dependencies

# Restart backend
sudo supervisorctl restart techresona-backend
```

### API Returns 502 Bad Gateway

```bash
# Check if backend is running
sudo supervisorctl status techresona-backend
netstat -tlnp | grep 9001

# If not running, check error logs
sudo tail -n 50 /var/log/supervisor/techresona-backend.err.log

# Restart services
sudo supervisorctl restart techresona-backend
sudo systemctl reload nginx
```

### Contact Form Not Working

```bash
# 1. Test backend directly
curl -X POST http://localhost:9001/api/enquiries \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@test.com","phone":"1234567890","message":"Test message"}'

# 2. Check browser console for errors (F12)
# 3. Check nginx error logs
sudo tail -f /var/log/nginx/error.log

# 4. Verify CORS headers
curl -I https://techresona.com/api/health
```

### Logo Appears Stretched

- This has been fixed in the latest build
- Logo now uses `object-fit: contain` and proper aspect ratio
- Clear browser cache: Ctrl+F5

### CSS Not Loading / Unstyled Content

- Fixed with critical CSS inlining
- Fonts preloaded for faster rendering
- Clear browser cache if issues persist

## 📊 Performance Optimizations Included

✅ WebP images with PNG fallbacks
✅ Responsive images for all screen sizes  
✅ Critical CSS inlined
✅ Font preloading
✅ Lazy loading for images
✅ Gzip compression
✅ Browser caching headers
✅ Minified HTML/CSS/JS
✅ Security headers
✅ HTTPS enforcement

## 🔐 Security Best Practices

1. **Always use HTTPS** - Configured in nginx
2. **Keep backend internal** - Only localhost:9001
3. **Update dependencies** regularly
4. **Use strong passwords** for SMTP/database
5. **Enable firewall** - Only ports 80, 443, 22
6. **Regular backups** - Database + files

## 📞 Support

- **Email:** support@techresona.com
- **Phone:** +91 9834346179
- **Location:** Kharadi, Pune, India

## ✅ Post-Deployment Checklist

- [ ] Backend running on localhost:9001
- [ ] Frontend accessible via HTTPS
- [ ] Contact form submits successfully
- [ ] Logo displays correctly (not stretched)
- [ ] All pages load without CSS issues
- [ ] Mobile responsive design works
- [ ] SSL certificate active
- [ ] Email notifications working (if configured)
- [ ] Slack notifications working (if configured)
- [ ] 404 page shows correctly
- [ ] Robots.txt accessible
- [ ] Sitemap.xml accessible

## 🎉 Congratulations!

Your TechResona website is now live and optimized! 

**Next Steps:**
1. Test the contact form
2. Monitor supervisor logs for enquiries
3. Set up email/Slack notifications
4. Configure Google Analytics (if needed)
5. Submit sitemap to Google Search Console

**Production URLs:**
- Website: https://techresona.com
- Contact: https://techresona.com/contact
- API Health: https://techresona.com/api/health (via nginx proxy)

---
Built with ❤️ by TechResona Team
EOF

echo "   ✓ Deployment guide created"
echo ""

# Display build stats
echo -e "${MAGENTA}📊 Build Statistics:${NC}"
echo ""
echo -e "${GREEN}Frontend Build:${NC}"
du -sh production-build/ | awk '{print "   Total size: " $1}'
file_count=$(find production-build -type f | wc -l)
echo "   Files: $file_count"
echo ""

echo -e "${GREEN}Assets:${NC}"
echo "   HTML pages:"
find production-build -name "*.html" -type f | wc -l | awk '{print "      " $1 " pages"}'
echo "   Images:"
find production-build/images -type f 2>/dev/null | wc -l | awk '{print "      " $1 " files"}'
echo "   Favicons:"
find production-build/favicons -type f 2>/dev/null | wc -l | awk '{print "      " $1 " files"}'
echo ""

echo -e "${GREEN}Backend:${NC}"
ls -lh production-build/backend/ | grep -E '\.(py|txt)$' | awk '{print "   " $9 " - " $5}'
echo ""

# Create deployment tarball
echo -e "${BLUE}📦 Creating aaPanel deployment package...${NC}"
tar -czf techresona-aapanel.tar.gz production-build/
tarball_size=$(du -sh techresona-aapanel.tar.gz | awk '{print $1}')
echo "   ✓ Created: techresona-aapanel.tar.gz ($tarball_size)"
echo ""

# Final summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Production Build Complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}📦 Ready for aaPanel Deployment:${NC}"
echo "   📁 Directory: production-build/"
echo "   📦 Package: techresona-aapanel.tar.gz ($tarball_size)"
echo ""
echo -e "${BLUE}🎯 What's Fixed:${NC}"
echo "   ✅ Logo aspect ratio (no more stretching)"
echo "   ✅ CSS loading optimized (cross-browser compatible)"
echo "   ✅ Contact form → localhost:9001"
echo "   ✅ All favicons optimized for every screen size"
echo "   ✅ Critical CSS inlined (prevents FOUC)"
echo "   ✅ Font preloading for faster rendering"
echo ""
echo -e "${BLUE}📋 Deployment Steps:${NC}"
echo "   1. Upload techresona-aapanel.tar.gz to your server"
echo "   2. Extract to /www/wwwroot/techresona.com/"
echo "   3. Follow production-build/AAPANEL_DEPLOYMENT_GUIDE.md"
echo "   4. Setup backend with supervisor (5 minutes)"
echo "   5. Configure nginx and SSL"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo "   • Backend runs on localhost:9001 (internal only)"
echo "   • Nginx proxies /api/* to backend"
echo "   • Frontend connects directly to localhost:9001"
echo "   • Update paths in nginx & supervisor configs"
echo "   • Create .env from .env.example"
echo ""
echo -e "${GREEN}🎉 Ready to deploy to aaPanel!${NC}"
echo ""
