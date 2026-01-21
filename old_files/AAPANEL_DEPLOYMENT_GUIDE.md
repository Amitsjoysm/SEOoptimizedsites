# aaPanel Deployment Guide for AstroWind

## 📦 Production Build Ready!

Your optimized static website is ready for deployment to aaPanel.

**Build Location:** `/app/dist/` (all production files)
**Compressed Archive:** `/app/astrowind-production-build.zip` (2.1 MB)

---

## 🚀 Deployment Methods

### Method 1: Direct Upload via aaPanel File Manager (Recommended)

#### Step 1: Download the Build
1. Download the file: `/app/astrowind-production-build.zip`
2. Size: ~2.1 MB (compressed)

#### Step 2: Access aaPanel
1. Log in to your aaPanel control panel
2. Go to **Website** → Select your domain
3. Click on **File Manager** or **Site Directory**

#### Step 3: Upload Files
1. Navigate to your website root directory (usually `/www/wwwroot/yourdomain.com/`)
2. **Important:** Clear existing files if this is a new deployment
3. Click **Upload** button
4. Upload `astrowind-production-build.zip`
5. Right-click the uploaded zip file → **Extract** → Extract to current directory
6. Delete the zip file after extraction

#### Step 4: Set Permissions
```bash
# Set correct permissions
chmod -R 755 /www/wwwroot/yourdomain.com/
chown -R www:www /www/wwwroot/yourdomain.com/
```

---

### Method 2: FTP/SFTP Upload

#### Step 1: Extract Locally
1. Download `/app/astrowind-production-build.zip`
2. Extract it on your local computer

#### Step 2: Connect via FTP
1. Use FileZilla, WinSCP, or any FTP client
2. Connect using your aaPanel FTP credentials:
   - **Host:** Your server IP or domain
   - **Port:** 21 (FTP) or 22 (SFTP)
   - **Username:** Your FTP username
   - **Password:** Your FTP password

#### Step 3: Upload Files
1. Navigate to `/www/wwwroot/yourdomain.com/`
2. Select all extracted files and folders
3. Upload to the root directory
4. Ensure folder structure is maintained:
   ```
   /www/wwwroot/yourdomain.com/
   ├── index.html
   ├── _astro/
   ├── about/
   ├── blog/
   ├── contact/
   ├── homes/
   ├── landing/
   ├── pricing/
   ├── services/
   ├── robots.txt
   ├── sitemap-index.xml
   └── rss.xml
   ```

---

### Method 3: SSH/Terminal Upload (Advanced)

If you have SSH access:

```bash
# On your server, navigate to website root
cd /www/wwwroot/yourdomain.com/

# Download the zip file (if hosted somewhere)
wget https://your-server/path/to/astrowind-production-build.zip

# Or use SCP to upload from local machine
scp astrowind-production-build.zip user@server:/www/wwwroot/yourdomain.com/

# Extract
unzip astrowind-production-build.zip

# Remove zip file
rm astrowind-production-build.zip

# Set permissions
chmod -R 755 .
chown -R www:www .
```

---

## ⚙️ aaPanel Configuration

### 1. Website Settings

#### PHP Version (Not Required)
- Your site is **pure static HTML** - no PHP needed!
- But if you want to set it: PHP 7.4+ is fine (won't be used)

#### SSL Certificate (Highly Recommended)
1. Go to **Website** → Your domain → **SSL**
2. Choose:
   - **Let's Encrypt** (Free) - Recommended
   - Or upload your own certificate
3. Enable **Force HTTPS**

### 2. Configure URL Rewriting

Create/edit `.htaccess` file in your website root:

```apache
# Enable Rewrite Engine
RewriteEngine On

# Force HTTPS (if SSL is enabled)
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]

# Remove trailing slashes
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)/$ /$1 [L,R=301]

# Clean URLs - serve HTML files without extension
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteCond %{REQUEST_FILENAME}.html -f
RewriteRule ^(.+)$ $1.html [L]

# Serve index.html for directory requests
DirectoryIndex index.html

# 404 Error Page
ErrorDocument 404 /404.html

# Enable Compression
<IfModule mod_deflate.c>
    AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
</IfModule>

# Browser Caching
<IfModule mod_expires.c>
    ExpiresActive On
    ExpiresByType image/jpg "access plus 1 year"
    ExpiresByType image/jpeg "access plus 1 year"
    ExpiresByType image/gif "access plus 1 year"
    ExpiresByType image/png "access plus 1 year"
    ExpiresByType image/webp "access plus 1 year"
    ExpiresByType text/css "access plus 1 month"
    ExpiresByType application/javascript "access plus 1 month"
    ExpiresByType text/html "access plus 1 day"
</IfModule>

# Security Headers
<IfModule mod_headers.c>
    Header set X-Content-Type-Options "nosniff"
    Header set X-Frame-Options "SAMEORIGIN"
    Header set X-XSS-Protection "1; mode=block"
    Header set Referrer-Policy "strict-origin-when-cross-origin"
</IfModule>
```

### 3. Nginx Configuration (If Using Nginx)

If your aaPanel site uses Nginx instead of Apache:

1. Go to **Website** → Your domain → **Config Files** → **Nginx Config**
2. Add this configuration:

```nginx
location / {
    try_files $uri $uri/ $uri.html /index.html;
    
    # Remove trailing slashes
    rewrite ^/(.*)/$ /$1 permanent;
}

# Error pages
error_page 404 /404.html;

# Gzip compression
gzip on;
gzip_vary on;
gzip_types text/plain text/css text/xml text/javascript application/javascript application/json image/svg+xml;
gzip_min_length 1000;

# Browser caching
location ~* \.(jpg|jpeg|png|gif|ico|css|js|webp|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Security headers
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "SAMEORIGIN" always;
add_header X-XSS-Protection "1; mode=block" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
```

---

## 🔧 Post-Deployment Configuration

### 1. Update Site URLs

Before deployment, update these files with your actual domain:

**File: `/app/astro.config.ts`** (Line 26)
```typescript
site: 'https://yourdomain.com',
```

**File: `/app/src/config.yaml`** (Line 3)
```yaml
site: 'https://yourdomain.com'
```

**File: `/app/public/robots.txt`** (Last line)
```
Sitemap: https://yourdomain.com/sitemap-index.xml
```

Then rebuild:
```bash
cd /app
npm run build
```

### 2. Test Your Deployment

After uploading, test these URLs:
- ✅ Homepage: `https://yourdomain.com/`
- ✅ About: `https://yourdomain.com/about`
- ✅ Blog: `https://yourdomain.com/blog`
- ✅ Contact: `https://yourdomain.com/contact`
- ✅ 404 Page: `https://yourdomain.com/nonexistent-page`
- ✅ Sitemap: `https://yourdomain.com/sitemap-index.xml`
- ✅ Robots: `https://yourdomain.com/robots.txt`
- ✅ RSS Feed: `https://yourdomain.com/rss.xml`

---

## 📊 Verify SEO & Performance

### 1. Google Search Console
1. Go to [Google Search Console](https://search.google.com/search-console)
2. Add your property
3. Submit sitemap: `https://yourdomain.com/sitemap-index.xml`

### 2. Test Tools
- **PageSpeed Insights:** https://pagespeed.web.dev/
- **Google Rich Results Test:** https://search.google.com/test/rich-results
- **Lighthouse:** Press F12 in Chrome → Lighthouse tab

### 3. Expected Scores
- Performance: 90-100
- Accessibility: 90-100
- SEO: 95-100
- Best Practices: 90-100

---

## 🐛 Troubleshooting

### Issue: 404 Errors on Navigation
**Solution:** Ensure `.htaccess` (Apache) or Nginx config is properly set up for clean URLs.

### Issue: Images Not Loading
**Solution:** 
1. Check file permissions: `chmod -R 755 /www/wwwroot/yourdomain.com/`
2. Verify `_astro` folder exists and has all image files

### Issue: CSS Not Loading
**Solution:**
1. Clear browser cache
2. Check `_astro` folder contains CSS files
3. Verify MIME types in aaPanel settings

### Issue: HTTPS Redirect Loop
**Solution:**
1. Remove duplicate HTTPS redirect rules
2. Check both `.htaccess` and aaPanel SSL settings
3. Ensure only one redirect method is active

### Issue: Sitemap Not Accessible
**Solution:**
1. Verify `sitemap-index.xml` exists in root
2. Check file permissions: `chmod 644 sitemap-index.xml`
3. Test: `curl https://yourdomain.com/sitemap-index.xml`

---

## 🔄 Updating Your Site

When you need to update your website:

1. Make changes locally
2. Rebuild: `npm run build`
3. Download new `/app/dist/` or `/app/astrowind-production-build.zip`
4. Upload and extract to your aaPanel website
5. Clear CDN cache if using one
6. Test the changes

---

## 📁 File Structure After Deployment

```
/www/wwwroot/yourdomain.com/
├── index.html                 # Homepage
├── 404.html                   # Error page
├── robots.txt                 # SEO robots file
├── sitemap-index.xml          # Main sitemap
├── sitemap-0.xml              # Sitemap pages
├── rss.xml                    # RSS feed
├── _headers                   # HTTP headers config
├── _astro/                    # Static assets (CSS, JS, Images)
│   ├── *.css                  # Optimized CSS
│   ├── *.js                   # Minified JavaScript
│   ├── *.webp                 # Optimized images
│   └── *.woff2                # Web fonts
├── about/
│   └── index.html             # About page
├── blog/
│   └── index.html             # Blog listing
├── contact/
│   └── index.html             # Contact page
├── homes/
│   ├── mobile-app/
│   ├── saas/
│   ├── personal/
│   └── startup/
├── landing/
│   ├── click-through/
│   ├── lead-generation/
│   ├── pre-launch/
│   ├── product/
│   ├── sales/
│   └── subscription/
├── pricing/
│   └── index.html             # Pricing page
└── services/
    └── index.html             # Services page
```

---

## ✅ Deployment Checklist

Before going live:
- [ ] Updated all URLs in config files
- [ ] Rebuilt the production build
- [ ] Uploaded all files to aaPanel
- [ ] Set correct file permissions (755 for folders, 644 for files)
- [ ] Configured .htaccess or Nginx rules
- [ ] Enabled SSL certificate
- [ ] Tested all major pages
- [ ] Verified sitemap is accessible
- [ ] Checked robots.txt
- [ ] Submitted sitemap to Google Search Console
- [ ] Ran PageSpeed Insights test
- [ ] Tested on mobile devices
- [ ] Verified forms work (if any)

---

## 🎯 Performance Tips

1. **Enable Cloudflare** (if available in aaPanel)
   - CDN for faster global delivery
   - Additional security
   - Automatic optimization

2. **Enable OPcache** (if using PHP fallback)
   - Go to aaPanel → PHP → Settings → Install OPcache

3. **Enable Redis Cache** (optional)
   - For dynamic features if you add them later

4. **Monitor Performance**
   - Use aaPanel's monitoring tools
   - Set up uptime monitoring
   - Track visitor analytics

---

## 📞 Support

If you encounter issues:
1. Check aaPanel error logs: **Website → Your Domain → Log**
2. Review browser console for JavaScript errors (F12)
3. Verify file permissions and ownership
4. Check aaPanel system status

---

## 🎉 You're Ready!

Your optimized AstroWind website is now ready for deployment to aaPanel. Follow the steps above for a smooth deployment experience.

**Build Info:**
- Total Pages: 36
- Build Time: ~15 seconds
- Total Size: ~2.1 MB (compressed)
- Framework: Astro 5.x
- Rendering: Static Site Generation (SSG)
- SEO: Fully optimized with structured data
