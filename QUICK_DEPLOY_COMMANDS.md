# 🚀 TechResona - Quick Deployment Commands for AAPanel

## 📦 Upload Package to Server

```bash
# From your local machine
scp /app/techresona-aapanel.tar.gz username@your-server-ip:~/
```

---

## 🔧 Server Setup (SSH into your AAPanel server)

### Step 1: Extract Package

```bash
# SSH into server
ssh username@your-server-ip

# Navigate to web root (adjust path based on your AAPanel setup)
cd ~/public_html/

# Or for some AAPanel setups:
# cd ~/www/techresona.com/

# Extract the package
tar -xzf ~/techresona-aapanel.tar.gz

# Verify extraction
ls -la
```

### Step 2: Setup Python Backend

```bash
# Navigate to backend directory
cd ~/public_html/backend

# Create virtual environment
python3 -m venv venv

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create .env file
nano .env
```

**Add to .env:**
```env
MONGO_URL=mongodb+srv://your-username:your-password@cluster.mongodb.net/techresona
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK
ENVIRONMENT=production
DEBUG=false
```

Save and exit (Ctrl+X, then Y, then Enter)

---

## 🔄 Start Backend Service

### Option 1: Using Supervisor (Recommended)

```bash
# Create supervisor config
sudo nano /etc/supervisor/conf.d/techresona-backend.conf
```

**Add this configuration:**
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

```bash
# Update supervisor and start service
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start techresona-backend

# Check status
sudo supervisorctl status techresona-backend
```

### Option 2: Using PM2

```bash
# Install PM2 globally (if not installed)
npm install -g pm2

# Start backend
cd ~/public_html/backend
pm2 start "venv/bin/uvicorn server:app --host 127.0.0.1 --port 8001 --workers 2" --name techresona-api

# Save PM2 configuration
pm2 save

# Setup PM2 to start on boot
pm2 startup
```

---

## 🌐 Configure Nginx

```bash
# Create or edit Nginx configuration
sudo nano /etc/nginx/sites-available/techresona.com
```

**Copy the content from `nginx-techresona.conf` in your package, or use this:**

```nginx
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

    # SSL Configuration (will be added by Certbot)
    ssl_certificate /etc/letsencrypt/live/techresona.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/techresona.com/privkey.pem;

    root /home/username/public_html;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_types text/plain text/css text/javascript application/javascript application/json;

    # API proxy to backend
    location /api/ {
        proxy_pass http://127.0.0.1:8001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static file caching
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Main location
    location / {
        try_files $uri $uri/ $uri.html /index.html;
    }
}
```

```bash
# Enable the site
sudo ln -s /etc/nginx/sites-available/techresona.com /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

---

## 🔒 Setup SSL Certificate (Let's Encrypt)

```bash
# Install Certbot (if not installed)
sudo apt-get update
sudo apt-get install certbot python3-certbot-nginx

# Obtain SSL certificate
sudo certbot --nginx -d techresona.com -d www.techresona.com

# Test auto-renewal
sudo certbot renew --dry-run
```

---

## ✅ Verification Commands

### Test Frontend
```bash
# Check homepage
curl -I https://techresona.com/

# Check blog
curl -I https://techresona.com/blog/

# Check featured post
curl -I https://techresona.com/blog/top-10-cloud-solutions-providers-india-2025/
```

### Test Backend API
```bash
# Health check
curl https://techresona.com/api/

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

### Check Logs
```bash
# Backend logs (Supervisor)
sudo tail -f /var/log/supervisor/techresona-backend.out.log
sudo tail -f /var/log/supervisor/techresona-backend.err.log

# Backend logs (PM2)
pm2 logs techresona-api

# Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

---

## 🔄 Service Management Commands

### Supervisor Commands
```bash
# Start
sudo supervisorctl start techresona-backend

# Stop
sudo supervisorctl stop techresona-backend

# Restart
sudo supervisorctl restart techresona-backend

# Status
sudo supervisorctl status techresona-backend

# View logs
sudo tail -f /var/log/supervisor/techresona-backend.out.log
```

### PM2 Commands
```bash
# Start
pm2 start techresona-api

# Stop
pm2 stop techresona-api

# Restart
pm2 restart techresona-api

# Status
pm2 status

# Logs
pm2 logs techresona-api

# Monitor
pm2 monit
```

### Nginx Commands
```bash
# Test configuration
sudo nginx -t

# Restart
sudo systemctl restart nginx

# Reload (without downtime)
sudo systemctl reload nginx

# Status
sudo systemctl status nginx
```

---

## 🗄️ MongoDB Setup (MongoDB Atlas)

### Create MongoDB Atlas Account
1. Go to https://www.mongodb.com/cloud/atlas
2. Sign up for free tier
3. Create a cluster (M0 Free tier)
4. Create database user
5. Whitelist IP addresses:
   ```bash
   # Get your server IP
   curl ifconfig.me
   ```
6. Get connection string
7. Update backend/.env with connection string

### Connection String Format
```
mongodb+srv://username:password@cluster.mongodb.net/techresona?retryWrites=true&w=majority
```

---

## 🛠️ Troubleshooting Commands

### Backend Not Starting
```bash
# Check Python version
python3 --version

# Check if virtual environment is activated
which python

# Check if uvicorn is installed
pip list | grep uvicorn

# Test backend manually
cd ~/public_html/backend
source venv/bin/activate
uvicorn server:app --host 127.0.0.1 --port 8001
```

### Nginx Issues
```bash
# Check if Nginx is running
sudo systemctl status nginx

# Check configuration syntax
sudo nginx -t

# Check if port 80/443 is in use
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443
```

### Database Connection Issues
```bash
# Test MongoDB connection
mongosh "your-connection-string"

# Check if backend can connect
cd ~/public_html/backend
source venv/bin/activate
python3 -c "from pymongo import MongoClient; import os; from dotenv import load_dotenv; load_dotenv(); print(os.getenv('MONGO_URL'))"
```

---

## 📊 Performance Testing

### PageSpeed Insights
```bash
# Open in browser
https://pagespeed.web.dev/analysis?url=https://techresona.com
```

### Load Time Test
```bash
# Test homepage load time
curl -o /dev/null -s -w '%{time_total}\n' https://techresona.com/

# Test API response time
curl -o /dev/null -s -w '%{time_total}\n' https://techresona.com/api/
```

---

## 🔄 Update Deployment (Future Updates)

```bash
# 1. Backup current version
cd ~/public_html
tar -czf backup-$(date +%Y%m%d).tar.gz .

# 2. Upload new package
scp new-techresona-aapanel.tar.gz username@your-server-ip:~/

# 3. Extract (overwrites existing files)
cd ~/public_html
tar -xzf ~/new-techresona-aapanel.tar.gz

# 4. Restart services
sudo supervisorctl restart techresona-backend
sudo systemctl reload nginx

# 5. Verify
curl -I https://techresona.com/
```

---

## 📋 Quick Reference

### File Permissions
```bash
# Set proper permissions
cd ~/public_html
chmod 755 .
chmod 644 *.html
chmod 600 backend/.env
chmod 755 backend/
```

### Check Disk Space
```bash
df -h
du -sh ~/public_html
```

### Monitor Resources
```bash
# CPU and memory usage
htop

# Or
top
```

### Check Service Status (All)
```bash
sudo supervisorctl status
pm2 status
sudo systemctl status nginx
```

---

## 🎯 Essential URLs After Deployment

- **Homepage:** https://techresona.com/
- **Blog:** https://techresona.com/blog/
- **Featured Post:** https://techresona.com/blog/top-10-cloud-solutions-providers-india-2025/
- **API Health:** https://techresona.com/api/
- **Sitemap:** https://techresona.com/sitemap-index.xml
- **RSS Feed:** https://techresona.com/rss.xml
- **Robots:** https://techresona.com/robots.txt

---

## 📞 Need Help?

Check these files in your package:
- `AAPANEL_DEPLOYMENT_GUIDE.md` - Detailed deployment instructions
- `DEPLOYMENT_PACKAGE_SUMMARY.md` - Complete package overview
- `SEO_OPTIMIZATION_GUIDE.md` - SEO implementation details

---

**Deployment Time:** 20-30 minutes  
**Difficulty:** Intermediate  
**Requirements:** SSH access, Python 3.8+, Nginx, MongoDB

*Happy Deploying! 🚀*
