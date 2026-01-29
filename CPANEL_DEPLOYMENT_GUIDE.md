# TechResona - cPanel Deployment Guide

## Overview
This guide covers deploying TechResona's full-stack application (Astro frontend + FastAPI backend) on a cPanel shared hosting environment.

## Prerequisites

### System Requirements
- cPanel account with SSH access
- Python 3.8+ support
- Node.js 18+ (for build process)
- MongoDB access (Atlas or local)
- Sufficient storage for application files (~100MB)

### Required Access
- SSH credentials
- cPanel file manager access
- Database credentials (MongoDB)
- Domain/subdomain configured

---

## Part 1: Build Production Files

### Step 1: Build Frontend (Astro)

```bash
# On your local machine or build server
cd /app

# Install dependencies
npm install

# Build production static site
npm run build

# This creates /app/dist/ directory with optimized static files
```

**Output**: The `dist/` folder contains your production-ready static site.

### Step 2: Prepare Backend Files

The backend is already production-ready. Ensure these files are present:

```
/app/backend/
├── server.py
├── requirements.txt
└── .env (create on server)
```

---

## Part 2: cPanel Server Setup

### Step 1: Upload Files

#### Option A: Using cPanel File Manager

1. Log into cPanel
2. Open **File Manager**
3. Navigate to `public_html/` (or your domain's root)
4. Create directory structure:
   ```
   public_html/
   ├── (frontend files from dist/ go here)
   └── api/
       └── (backend files go here)
   ```

5. **Upload Frontend**:
   - Upload all contents of `/app/dist/*` to `public_html/`
   - Upload `/app/.htaccess` to `public_html/`

6. **Upload Backend**:
   - Create folder: `public_html/api/`
   - Upload all files from `/app/backend/` to `public_html/api/`

#### Option B: Using SCP/SFTP

```bash
# Upload frontend
scp -r /app/dist/* username@yourserver.com:~/public_html/
scp /app/.htaccess username@yourserver.com:~/public_html/

# Upload backend
scp -r /app/backend/* username@yourserver.com:~/public_html/api/
```

### Step 2: Setup Python Virtual Environment

```bash
# SSH into your cPanel server
ssh username@yourserver.com

# Navigate to backend directory
cd ~/public_html/api

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install --upgrade pip
pip install -r requirements.txt
```

### Step 3: Configure Environment Variables

Create `.env` file in `~/public_html/api/`:

```bash
cd ~/public_html/api
nano .env
```

Add the following:

```env
# MongoDB Configuration
MONGO_URL=mongodb://your-mongodb-connection-string

# Slack Webhook (optional)
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL

# Application Settings
ENVIRONMENT=production
DEBUG=false
```

Save and exit (Ctrl+X, then Y, then Enter)

### Step 4: Setup Backend Service

#### Option A: Using Passenger (Recommended for cPanel)

Create `passenger_wsgi.py` in `~/public_html/api/`:

```python
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
```

#### Option B: Using Systemd Service (if available)

Create `/etc/systemd/system/techresona-backend.service`:

```ini
[Unit]
Description=TechResona FastAPI Backend
After=network.target

[Service]
User=your-username
Group=your-group
WorkingDirectory=/home/username/public_html/api
Environment="PATH=/home/username/public_html/api/venv/bin"
ExecStart=/home/username/public_html/api/venv/bin/uvicorn server:app --host 127.0.0.1 --port 8001 --workers 2
Restart=always

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl enable techresona-backend
sudo systemctl start techresona-backend
sudo systemctl status techresona-backend
```

#### Option C: Using PM2 (Node Process Manager)

```bash
# Install PM2 globally
npm install -g pm2

# Start backend with PM2
cd ~/public_html/api
pm2 start "venv/bin/uvicorn server:app --host 127.0.0.1 --port 8001" --name techresona-api

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
```

---

## Part 3: Configure Domain and SSL

### Step 1: Domain Configuration

1. In cPanel, go to **Domains**
2. Ensure your domain points to `public_html/`
3. If using subdomain, create it and point to `public_html/`

### Step 2: SSL Certificate

1. In cPanel, go to **SSL/TLS Status**
2. Enable **AutoSSL** for automatic free SSL certificate
3. Or manually install Let's Encrypt certificate
4. Force HTTPS (already configured in .htaccess)

---

## Part 4: MongoDB Setup

### Option A: MongoDB Atlas (Recommended)

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create free cluster
3. Add database user
4. Whitelist IP addresses (or use 0.0.0.0/0 for all)
5. Get connection string
6. Update `.env` file with connection string

### Option B: Local MongoDB (if supported)

```bash
# Install MongoDB (if not installed)
sudo apt-get install mongodb

# Start MongoDB
sudo systemctl start mongodb
sudo systemctl enable mongodb

# Connection string
MONGO_URL=mongodb://localhost:27017
```

---

## Part 5: Verification and Testing

### Step 1: Test Frontend

```bash
# Visit your domain
https://yourdomain.com

# Check if pages load:
- Homepage: https://yourdomain.com/
- Blog: https://yourdomain.com/blog/
- Services: https://yourdomain.com/cloud-solutions/
```

### Step 2: Test Backend API

```bash
# Test API health
curl https://yourdomain.com/api/

# Expected response:
{"status": "active", "message": "TechResona API is running"}

# Test contact form
curl -X POST https://yourdomain.com/api/enquiry \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "1234567890",
    "message": "Test message"
  }'
```

### Step 3: Check Backend Logs

```bash
# If using systemd
sudo journalctl -u techresona-backend -f

# If using PM2
pm2 logs techresona-api

# Manual log file
tail -f ~/public_html/api/app.log
```

---

## Part 6: Performance Optimization

### Step 1: Enable Caching

Already configured in `.htaccess`. Verify:

```bash
curl -I https://yourdomain.com/
# Look for: Cache-Control, Expires headers
```

### Step 2: Enable Compression

```bash
# Check if gzip is working
curl -H "Accept-Encoding: gzip" -I https://yourdomain.com/
# Look for: Content-Encoding: gzip
```

### Step 3: Image Optimization

All images are already optimized and served from CDN (Unsplash).
Local images in `/public/images/` are compressed.

---

## Part 7: Maintenance

### Backup Strategy

```bash
# Automated daily backup script
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR=~/backups

# Backup files
tar -czf $BACKUP_DIR/techresona-$DATE.tar.gz ~/public_html

# Backup database (if local MongoDB)
mongodump --out=$BACKUP_DIR/mongo-$DATE

# Keep only last 7 days
find $BACKUP_DIR -name "techresona-*.tar.gz" -mtime +7 -delete
```

### Update Deployment

```bash
# 1. Build new version locally
npm run build

# 2. Backup current version
cd ~/public_html
tar -czf backup-$(date +%Y%m%d).tar.gz .

# 3. Upload new files
scp -r /app/dist/* username@yourserver.com:~/public_html/

# 4. Restart backend
pm2 restart techresona-api
# OR
sudo systemctl restart techresona-backend

# 5. Clear browser cache and test
```

### Monitoring

```bash
# Check backend status
pm2 status
# OR
sudo systemctl status techresona-backend

# Monitor resource usage
htop

# Check disk space
df -h

# Monitor logs
tail -f ~/public_html/api/app.log
```

---

## Part 8: Troubleshooting

### Issue: 404 Errors on Routes

**Solution**: Ensure `.htaccess` file is in `public_html/` root and mod_rewrite is enabled.

```bash
# Check if .htaccess exists
ls -la ~/public_html/.htaccess

# Verify mod_rewrite (contact host if not enabled)
```

### Issue: API Not Responding

**Solution**: Check backend service status

```bash
# Check if backend is running
pm2 status
# OR
sudo systemctl status techresona-backend

# Check port 8001
netstat -tlnp | grep 8001

# Restart if needed
pm2 restart techresona-api
```

### Issue: Database Connection Failed

**Solution**: Verify MongoDB connection

```bash
# Test MongoDB connection
mongosh "your-connection-string"

# Check .env file
cat ~/public_html/api/.env | grep MONGO_URL

# Check MongoDB Atlas IP whitelist
```

### Issue: Images Not Loading

**Solution**: Check file permissions

```bash
# Fix permissions
cd ~/public_html
chmod 755 images/
chmod 644 images/*
```

### Issue: SSL Certificate Errors

**Solution**: Renew or reinstall SSL

```bash
# Using cPanel SSL interface
# Or manually with certbot
sudo certbot --apache -d yourdomain.com
```

---

## Part 9: Security Checklist

- [ ] SSL certificate installed and HTTPS enforced
- [ ] `.env` file has correct permissions (600)
- [ ] MongoDB connection uses authentication
- [ ] Backend only accessible via localhost
- [ ] Security headers configured in `.htaccess`
- [ ] Regular backups automated
- [ ] Firewall configured (if applicable)
- [ ] Keep Python packages updated
- [ ] Monitor logs for suspicious activity
- [ ] Rate limiting configured (if needed)

---

## Part 10: Support and Resources

### Useful Commands

```bash
# Check Python version
python3 --version

# Check Node version  
node --version

# List all processes
pm2 list

# View real-time logs
pm2 logs --lines 100

# Restart all services
pm2 restart all

# Check server resources
htop

# Test API endpoint
curl https://yourdomain.com/api/
```

### Contact Information

**TechResona Support**
- Website: https://techresona.com
- Email: support@techresona.com
- Documentation: https://techresona.com/docs

---

## Summary

Your TechResona application is now fully deployed on cPanel! 

**What's Working:**
✅ Static Astro frontend served from `public_html/`
✅ FastAPI backend running on localhost:8001
✅ API routes proxied via .htaccess
✅ MongoDB connected and storing data
✅ SSL certificate installed
✅ Images optimized and cached
✅ Blog posts accessible at /blog/
✅ Contact form functional
✅ SEO-optimized pages

**Next Steps:**
1. Configure domain DNS if not done
2. Test all forms and features
3. Setup monitoring and alerts
4. Configure automated backups
5. Add analytics tracking

**Performance Expectations:**
- Page load time: < 2 seconds
- API response time: < 500ms
- Uptime: 99.9%
- Mobile performance: 90+ Lighthouse score

---

*Last Updated: January 29, 2025*
*Version: 1.0*
