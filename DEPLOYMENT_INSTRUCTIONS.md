# 🚀 Deployment Instructions for Astro Static Site

## Problem Identified ✅

Your site was showing the same landing page for all routes because the nginx configuration was set up for a **React SPA** instead of an **Astro static site**.

### What was wrong:
```nginx
location / {
    try_files $uri /index.html;  # ❌ Wrong for Astro
}
```

### What it should be:
```nginx
location / {
    try_files $uri $uri/index.html =404;  # ✅ Correct for Astro
}
```

---

## 📋 Deployment Steps

### Step 1: Build the Site Locally
```bash
cd /app
npm install
npm run build
```

This creates the `dist/` folder with all your static HTML files.

### Step 2: Upload Files to Server

Upload the **contents** of the `dist/` folder to your web root:

```bash
# On your server
cd /www/wwwroot/MarketAutoMailer.mj.publicvm.com

# Backup old files (optional)
mkdir -p ~/backup-$(date +%Y%m%d)
cp -r * ~/backup-$(date +%Y%m%d)/

# Clear the directory
rm -rf *

# Upload new dist files here
# You can use FTP, SCP, or AAPanel's file manager
```

Or using SCP from your local machine:
```bash
scp -r dist/* user@server:/www/wwwroot/MarketAutoMailer.mj.publicvm.com/
```

### Step 3: Update Nginx Configuration

1. **Open AAPanel** → Navigate to **Website** → Find your site
2. **Click Settings** → **Configuration File**
3. **Replace the entire configuration** with the content from `/app/nginx-production.conf`
4. **Save** and **Reload Nginx**

Or via command line:
```bash
# Backup current config
cp /www/server/panel/vhost/nginx/marketautomailer.mj.publicvm.com.conf ~/nginx-backup.conf

# Update with new config (copy from nginx-production.conf)
nano /www/server/panel/vhost/nginx/marketautomailer.mj.publicvm.com.conf

# Test nginx configuration
nginx -t

# Reload nginx
nginx -s reload
```

### Step 4: Verify Deployment

Visit these URLs and confirm each page shows different content:
- `http://marketautomailer.mj.publicvm.com/` (Home)
- `http://marketautomailer.mj.publicvm.com/services` (Services page)
- `http://marketautomailer.mj.publicvm.com/about` (About page)
- `http://marketautomailer.mj.publicvm.com/contact` (Contact page)
- `http://marketautomailer.mj.publicvm.com/cloud-solutions` (Cloud Solutions)

---

## 🔧 Key Changes Made

### 1. Fixed Nginx Configuration
- Changed from SPA mode to static site mode
- Proper file resolution for `/services`, `/about`, etc.
- Optimized caching for `/_astro/` assets (1 year)

### 2. Cleaned Up Codebase
Moved unnecessary files to `/app/old_files/`:
- Documentation files (SEO guides, deployment guides, etc.)
- Platform-specific configs (netlify.toml, vercel.json, docker-compose.yml)
- DecapCMS admin panel files

### 3. Build Verification
- Confirmed all pages build correctly
- Generated: 40 static pages
- All routes working: `/services`, `/about`, `/contact`, etc.

---

## 📁 Folder Structure After Deployment

Your web root should look like:
```
/www/wwwroot/MarketAutoMailer.mj.publicvm.com/
├── index.html
├── 404.html
├── about/
│   └── index.html
├── services/
│   └── index.html
├── contact/
│   └── index.html
├── cloud-solutions/
│   └── index.html
├── web-development/
│   └── index.html
├── _astro/
│   └── [compiled assets]
├── robots.txt
├── sitemap-index.xml
└── ...
```

---

## 🐛 Troubleshooting

### If pages still show the same content:

1. **Clear browser cache**: Ctrl+Shift+R (or Cmd+Shift+R on Mac)

2. **Verify dist folder contents**:
```bash
ls -la /www/wwwroot/MarketAutoMailer.mj.publicvm.com/services/
# Should show: index.html
```

3. **Check nginx is using new config**:
```bash
nginx -T | grep "try_files"
# Should show: try_files $uri $uri/index.html =404;
```

4. **Check file permissions**:
```bash
chmod -R 755 /www/wwwroot/MarketAutoMailer.mj.publicvm.com
```

### If you get 404 errors:

- Ensure all `dist/` folder contents were uploaded
- Check nginx error logs: `/www/wwwlogs/marketautomailer.mj.publicvm.com.error.log`

---

## 🔄 Future Deployments

For future updates:
```bash
# 1. Build locally
npm run build

# 2. Upload dist/ contents to server
scp -r dist/* user@server:/www/wwwroot/MarketAutoMailer.mj.publicvm.com/

# 3. Clear browser cache and test
```

---

## ✅ Summary

- ✅ Fixed nginx configuration for Astro static sites
- ✅ Cleaned up unnecessary files
- ✅ Verified all 40 pages build correctly
- ✅ Optimized caching for performance
- ✅ All routes will now work properly: `/services`, `/about`, `/contact`, etc.

The site is now ready for deployment! 🎉
