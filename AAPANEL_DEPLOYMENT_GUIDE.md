# TechResona - aPanel Deployment Guide

## Overview
This guide covers deploying TechResona's full-stack application (Astro frontend + FastAPI backend) on an aPanel hosting environment with both services running on the same server.

## Prerequisites

### System Requirements
- aPanel account with SSH access
- Python 3.8+ support
- Node.js 18+ (for build process)
- MongoDB access (Atlas or local)
- Sufficient storage for application files (~100MB)

### Required Access
- SSH credentials
- aPanel file manager access
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

## Part 2: aPanel Server Setup

### Step 1: Upload Files

#### Option A: Using aPanel File Manager

1. Log into aPanel
2. Open **File Manager**
3. Navigate to your domain's root directory (usually `public_html/` or `www/`)
4. Create directory structure:
   ```
   public_html/
   ├── (frontend files from dist/ go here)
   └── backend/
       └── (backend files go here)
   ```

5. **Upload Frontend**:
   - Upload all contents of `/app/dist/*` to `public_html/`
   - Upload `/app/.htaccess` to `public_html/`

6. **Upload Backend**:
   - Create folder: `public_html/backend/`
   - Upload all files from `/app/backend/` to `public_html/backend/`

#### Option B: Using SCP/SFTP

```bash
# Upload frontend
scp -r /app/dist/* username@yourserver.com:~/public_html/
scp /app/.htaccess username@yourserver.com:~/public_html/

# Upload backend
scp -r /app/backend/* username@yourserver.com:~/public_html/backend/
```

### Step 2: Setup Python Virtual Environment

```bash
# SSH into your aPanel server
ssh username@yourserver.com

# Navigate to backend directory
cd ~/public_html/backend

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

### Step 3: Configure Environment Variables

Create `.env` file in `~/public_html/backend/`:

```bash
cd ~/public_html/backend
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

### Step 4: Setup Backend Service on aPanel

#### Method 1: Using Supervisor (Recommended)

Create supervisor configuration:

```bash
sudo nano /etc/supervisor/conf.d/techresona-backend.conf
```

Add the following:

```ini
[program:techresona-backend]
command=/home/username/public_html/backend/venv/bin/uvicorn server:app --host 127.0.0.1 --port 8001 --workers 2
directory=/home/username/public_html/backend
user=username
autostart=true
autorestart=true
stderr_logfile=/var/log/supervisor/techresona-backend.err.log
stdout_logfile=/var/log/supervisor/techresona-backend.out.log
environment=PATH="/home/username/public_html/backend/venv/bin"
```

Start the service:

```bash
# Update supervisor
sudo supervisorctl reread
sudo supervisorctl update

# Start backend
sudo supervisorctl start techresona-backend

# Check status
sudo supervisorctl status techresona-backend
```

#### Method 2: Using Systemd Service

Create service file:

```bash
sudo nano /etc/systemd/system/techresona-backend.service
```

Add:

```ini
[Unit]
Description=TechResona FastAPI Backend
After=network.target

[Service]
User=username
Group=username
WorkingDirectory=/home/username/public_html/backend
Environment="PATH=/home/username/public_html/backend/venv/bin"
ExecStart=/home/username/public_html/backend/venv/bin/uvicorn server:app --host 127.0.0.1 --port 8001 --workers 2
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable techresona-backend
sudo systemctl start techresona-backend
sudo systemctl status techresona-backend
```

#### Method 3: Using PM2

```bash
# Install PM2 globally
npm install -g pm2

# Navigate to backend
cd ~/public_html/backend

# Start backend with PM2
pm2 start "venv/bin/uvicorn server:app --host 127.0.0.1 --port 8001 --workers 2" --name techresona-api

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
```

---

## Part 3: Configure Nginx for aPanel

### Step 1: Create Nginx Configuration

aPanel typically uses Nginx. Create or update your site configuration:

```bash
sudo nano /etc/nginx/sites-available/techresona.com
```

Add the following configuration:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name techresona.com www.techresona.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name techresona.com www.techresona.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/techresona.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/techresona.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    # Root directory
    root /home/username/public_html;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/javascript application/json application/xml+rss;

    # API Routes - Proxy to Backend
    location /api/ {
        proxy_pass http://127.0.0.1:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 90;
    }

    # Static files caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Blog routes
    location /blog/ {
        try_files $uri $uri/ $uri.html =404;
    }

    # All other routes - serve index.html for client-side routing
    location / {
        try_files $uri $uri/ $uri.html /index.html;
    }

    # Deny access to sensitive files
    location ~ /\. {
        deny all;
    }

    location ~ \.(env|log|md)$ {
        deny all;
    }
}
```

Enable the site and restart Nginx:

```bash
# Create symbolic link
sudo ln -s /etc/nginx/sites-available/techresona.com /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## Part 4: SSL Certificate Setup

### Using Let's Encrypt (Certbot)

```bash
# Install Certbot
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d techresona.com -d www.techresona.com

# Auto-renewal is configured automatically
# Test renewal
sudo certbot renew --dry-run
```

---

## Part 5: MongoDB Setup

### Option A: MongoDB Atlas (Recommended)

1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create free cluster
3. Add database user
4. Whitelist IP addresses:
   - Get your server IP: `curl ifconfig.me`
   - Add to Atlas IP whitelist
5. Get connection string
6. Update `.env` file with connection string:

```env
MONGO_URL=mongodb+srv://username:password@cluster.mongodb.net/techresona?retryWrites=true&w=majority
```

### Option B: Local MongoDB

```bash
# Install MongoDB
sudo apt-get install mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod

# Verify
sudo systemctl status mongod

# Connection string
MONGO_URL=mongodb://localhost:27017/techresona
```

---

## Part 6: Verification and Testing

### Step 1: Test Frontend

```bash
# Visit your domain
https://techresona.com

# Check if pages load:
- Homepage: https://techresona.com/
- Blog: https://techresona.com/blog/
- Cloud Solutions: https://techresona.com/cloud-solutions/
- AI Automation: https://techresona.com/ai-automation/
```

### Step 2: Test Backend API

```bash
# Test API health
curl https://techresona.com/api/

# Expected response:
{"status": "active", "message": "TechResona API is running"}

# Test contact form
curl -X POST https://techresona.com/api/enquiry \
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
# If using Supervisor
sudo tail -f /var/log/supervisor/techresona-backend.out.log
sudo tail -f /var/log/supervisor/techresona-backend.err.log

# If using Systemd
sudo journalctl -u techresona-backend -f

# If using PM2
pm2 logs techresona-api
```

### Step 4: Check Nginx Logs

```bash
# Access logs
sudo tail -f /var/log/nginx/access.log

# Error logs
sudo tail -f /var/log/nginx/error.log
```

---

## Part 7: Performance Optimization

### Step 1: Enable HTTP/2

Already configured in Nginx configuration above.

### Step 2: Configure Browser Caching

Already configured in Nginx configuration with proper cache headers.

### Step 3: Enable Gzip Compression

Already configured in Nginx configuration.

### Step 4: Optimize Backend Workers

```bash
# Adjust number of workers based on CPU cores
# Rule: workers = (2 x CPU cores) + 1

# Check CPU cores
nproc

# Update uvicorn command with appropriate workers
# For 2 cores: --workers 5
# For 4 cores: --workers 9
```

---

## Part 8: Monitoring and Maintenance

### Setup Monitoring

```bash
# Monitor backend service
watch -n 5 'sudo supervisorctl status techresona-backend'

# Monitor system resources
htop

# Monitor disk usage
df -h

# Monitor nginx status
sudo systemctl status nginx
```

### Automated Backups

Create backup script:

```bash
sudo nano /usr/local/bin/backup-techresona.sh
```

Add:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/username/backups"
APP_DIR="/home/username/public_html"

mkdir -p $BACKUP_DIR

# Backup application files
tar -czf $BACKUP_DIR/techresona-$DATE.tar.gz -C $APP_DIR .

# Backup MongoDB (if local)
mongodump --out=$BACKUP_DIR/mongo-$DATE --db=techresona

# Keep only last 7 days
find $BACKUP_DIR -name "techresona-*.tar.gz" -mtime +7 -delete
find $BACKUP_DIR -name "mongo-*" -type d -mtime +7 -exec rm -rf {} +

echo "Backup completed: $DATE"
```

Make executable and schedule:

```bash
sudo chmod +x /usr/local/bin/backup-techresona.sh

# Add to crontab (daily at 2 AM)
crontab -e
0 2 * * * /usr/local/bin/backup-techresona.sh >> /var/log/techresona-backup.log 2>&1
```

---

## Part 9: Update Deployment

### Updating the Application

```bash
# 1. Build new version locally
cd /app
npm run build

# 2. Backup current version on server
ssh username@yourserver.com
cd ~/public_html
tar -czf backup-$(date +%Y%m%d).tar.gz dist/ backend/

# 3. Upload new frontend files
scp -r /app/dist/* username@yourserver.com:~/public_html/

# 4. If backend changed, upload backend
scp /app/backend/server.py username@yourserver.com:~/public_html/backend/

# 5. Restart services
ssh username@yourserver.com
sudo supervisorctl restart techresona-backend
sudo systemctl reload nginx

# 6. Verify deployment
curl https://techresona.com/api/
```

---

## Part 10: Troubleshooting

### Issue: 502 Bad Gateway

**Cause**: Backend service not running

**Solution**:
```bash
# Check backend status
sudo supervisorctl status techresona-backend

# Restart if needed
sudo supervisorctl restart techresona-backend

# Check logs
sudo tail -f /var/log/supervisor/techresona-backend.err.log
```

### Issue: 404 on API Routes

**Cause**: Nginx proxy configuration issue

**Solution**:
```bash
# Test nginx configuration
sudo nginx -t

# Check if backend is listening
netstat -tlnp | grep 8001

# Restart nginx
sudo systemctl restart nginx
```

### Issue: Database Connection Failed

**Solution**:
```bash
# Check .env file
cat ~/public_html/backend/.env

# Test MongoDB connection
mongosh "your-connection-string"

# Check MongoDB Atlas IP whitelist
# Add server IP to whitelist
```

### Issue: High Memory Usage

**Solution**:
```bash
# Check memory usage
free -h

# Reduce uvicorn workers
# Edit supervisor config and reduce --workers
sudo nano /etc/supervisor/conf.d/techresona-backend.conf
sudo supervisorctl restart techresona-backend
```

### Issue: Slow Page Load

**Solution**:
```bash
# Check if gzip is enabled
curl -H "Accept-Encoding: gzip" -I https://techresona.com/

# Verify caching headers
curl -I https://techresona.com/

# Check nginx error logs
sudo tail -f /var/log/nginx/error.log
```

---

## Part 11: Security Checklist

- [ ] SSL certificate installed and auto-renewal configured
- [ ] HTTPS enforced (HTTP redirects to HTTPS)
- [ ] `.env` file has restricted permissions (600)
- [ ] MongoDB uses authentication and SSL
- [ ] Backend only accessible via localhost (127.0.0.1)
- [ ] Security headers configured in Nginx
- [ ] Firewall configured (UFW recommended)
- [ ] Regular backups automated
- [ ] Keep system packages updated
- [ ] Monitor logs regularly
- [ ] Disable unnecessary services
- [ ] Use strong passwords
- [ ] Enable fail2ban for SSH protection

### Setup Firewall (UFW)

```bash
# Install UFW
sudo apt-get install ufw

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP/HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

---

## Part 12: Performance Metrics

### Expected Performance

- **Page Load Time**: < 2 seconds
- **API Response Time**: < 500ms
- **Time to First Byte (TTFB)**: < 600ms
- **First Contentful Paint (FCP)**: < 1.8s
- **Largest Contentful Paint (LCP)**: < 2.5s
- **Cumulative Layout Shift (CLS)**: < 0.1
- **First Input Delay (FID)**: < 100ms

### Monitoring Tools

```bash
# Check page speed
curl -o /dev/null -s -w '%{time_total}\n' https://techresona.com/

# Monitor API response time
curl -o /dev/null -s -w '%{time_total}\n' https://techresona.com/api/

# Use external tools
# - Google PageSpeed Insights
# - GTmetrix
# - Pingdom
```

---

## Summary

🎉 **Your TechResona application is now fully deployed on aPanel!**

### What's Deployed:

✅ **Frontend (Astro)**
- Static site built and optimized
- Served by Nginx from `public_html/`
- All pages accessible with clean URLs
- Blog posts at `/blog/`
- Images optimized and cached

✅ **Backend (FastAPI)**
- Running on localhost:8001
- Proxied through Nginx at `/api/*`
- MongoDB connected
- Contact form functional
- Auto-restart on failure

✅ **Infrastructure**
- SSL certificate installed
- HTTPS enforced
- Gzip compression enabled
- Browser caching configured
- Security headers in place

### Quick Commands Reference

```bash
# Check backend status
sudo supervisorctl status techresona-backend

# Restart backend
sudo supervisorctl restart techresona-backend

# Restart Nginx
sudo systemctl restart nginx

# View backend logs
sudo tail -f /var/log/supervisor/techresona-backend.out.log

# View Nginx logs
sudo tail -f /var/log/nginx/access.log

# Test API
curl https://techresona.com/api/

# Check SSL certificate
sudo certbot certificates
```

### Support

**TechResona Support**
- Website: https://techresona.com
- Email: support@techresona.com
- Phone: +91-XXXXXXXXXX

---

*Last Updated: January 29, 2025*
*Version: 1.0 - aPanel Deployment*
