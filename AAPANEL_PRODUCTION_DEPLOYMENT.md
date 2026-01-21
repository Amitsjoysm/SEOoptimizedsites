# 🚀 AAPanel Production Deployment Guide - Complete

## 📋 Pre-Deployment Configuration

### IMPORTANT: Update These Settings Before Building

#### 1. Update Site URL
**File:** `/app/astro.config.ts`
```typescript
export default defineConfig({
  output: 'static',
  site: 'https://YOUR-DOMAIN.com',  // ⚠️ CHANGE THIS
  // ...
});
```

#### 2. Update Site Configuration
**File:** `/app/src/config.yaml`
```yaml
site:
  name: 'Your Site Name'           # ⚠️ CHANGE THIS
  site: 'https://YOUR-DOMAIN.com'  # ⚠️ CHANGE THIS
  base: '/'
  
metadata:
  title:
    default: 'Your Site Name'
    template: '%s — Your Site Name'
  description: 'Your site description'
  
  twitter:
    handle: '@your_handle'
    site: '@your_handle'
```

#### 3. Update robots.txt
**File:** `/app/public/robots.txt`
```
User-agent: *
Allow: /
Disallow: /admin/
Disallow: /decapcms/
Disallow: /_astro/

Sitemap: https://YOUR-DOMAIN.com/sitemap-index.xml  # ⚠️ CHANGE THIS
```

#### 4. Update DecapCMS Backend (If Using)
**File:** `/app/public/decapcms/config.yml`
```yaml
backend:
  name: github
  repo: YOUR_USERNAME/YOUR_REPO_NAME  # ⚠️ CHANGE THIS
  branch: main
```

---

## 🔨 Build Process

### Step 1: Install Dependencies
```bash
cd /app
npm install
```

### Step 2: Build Production Site
```bash
npm run build
```

**Expected Output:**
- ✅ 45+ pages generated
- ✅ Images optimized
- ✅ CSS/HTML compressed
- ✅ Sitemap generated
- ✅ Build time: ~15-20 seconds

**Output Location:** `/app/dist/`

### Step 3: Create Deployment Archive
```bash
cd /app
zip -r astrowind-production-build.zip dist/
```

Or create tar.gz:
```bash
tar -czf astrowind-production-build.tar.gz -C dist .
```

---

## 📦 Deployment to AAPanel

### Method 1: Upload via AAPanel File Manager (Easiest)

#### Step 1: Access AAPanel
1. Login to AAPanel: `http://YOUR-SERVER-IP:7800`
2. Navigate to **Website** → Your Domain
3. Click **File Manager** or **Site Directory**

#### Step 2: Prepare Directory
1. Go to your website root: `/www/wwwroot/yourdomain.com/`
2. **Backup existing files** (if any):
   - Select all files → Download or create backup
3. **Delete old files** to start fresh

#### Step 3: Upload Build
1. Download `/app/astrowind-production-build.zip` from your development environment
2. In AAPanel File Manager, click **Upload**
3. Upload the zip file
4. Right-click zip file → **Extract** → Extract here
5. Move contents from `dist/` folder to root if needed:
   ```bash
   # Via AAPanel Terminal
   cd /www/wwwroot/yourdomain.com/
   mv dist/* .
   rmdir dist
   rm astrowind-production-build.zip
   ```

#### Step 4: Set Permissions
In AAPanel Terminal:
```bash
cd /www/wwwroot/yourdomain.com/
chmod -R 755 .
chown -R www:www .
```

#### Step 5: Configure Nginx (AAPanel handles this automatically)
AAPanel automatically configures Nginx for static sites. Verify in:
- **Website** → Your Domain → **Config** → **Configuration File**

Should look like:
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

---

### Method 2: Direct Server Upload via SCP/SFTP

#### Using SCP (Command Line)
```bash
# From your local machine
scp astrowind-production-build.zip root@YOUR-SERVER-IP:/www/wwwroot/yourdomain.com/

# Then SSH into server
ssh root@YOUR-SERVER-IP
cd /www/wwwroot/yourdomain.com/
unzip astrowind-production-build.zip
mv dist/* .
rmdir dist
rm astrowind-production-build.zip
chmod -R 755 .
chown -R www:www .
```

#### Using SFTP Client (FileZilla/WinSCP)
1. Connect to your server:
   - Protocol: SFTP
   - Host: YOUR-SERVER-IP
   - Port: 22 (or your SSH port)
   - Username: root (or your user)
   - Password: your SSH password

2. Navigate to: `/www/wwwroot/yourdomain.com/`

3. Upload all files from `/app/dist/` directory

4. Set permissions via terminal (see above)

---

### Method 3: Git Deployment (Automated)

#### Setup Git Hook on AAPanel Server
```bash
# On server
cd /www/wwwroot/yourdomain.com/
git init
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Create post-receive hook
mkdir -p .git/hooks
nano .git/hooks/post-receive
```

Add to post-receive:
```bash
#!/bin/bash
cd /www/wwwroot/yourdomain.com
git pull origin main
npm install
npm run build
mv dist/* .
rmdir dist
```

Make executable:
```bash
chmod +x .git/hooks/post-receive
```

---

## ✅ Post-Deployment Verification

### 1. Test Website Access
```bash
# Test main site
curl -I https://yourdomain.com

# Should return: HTTP/2 200
```

### 2. Check Key Pages
Visit these URLs in browser:
- ✅ Homepage: `https://yourdomain.com/`
- ✅ Blog: `https://yourdomain.com/blog/`
- ✅ SEO Tools: `https://yourdomain.com/seo-tools/`
- ✅ Sample Post: `https://yourdomain.com/advanced-seo-guide-2025/`
- ✅ Admin Panel: `https://yourdomain.com/decapcms/` (if configured)
- ✅ Sitemap: `https://yourdomain.com/sitemap-index.xml`
- ✅ Robots: `https://yourdomain.com/robots.txt`

### 3. Verify SEO Elements
```bash
# Check if structured data exists
curl https://yourdomain.com/advanced-seo-guide-2025/ | grep 'application/ld+json'

# Should show JSON-LD schema markup
```

### 4. Test Performance
- [Google PageSpeed Insights](https://pagespeed.web.dev/)
- [GTmetrix](https://gtmetrix.com/)
- Expected scores: 90-100 (Performance, SEO, Accessibility)

### 5. Verify SSL Certificate
- AAPanel should auto-install Let's Encrypt SSL
- Check: **Website** → Your Domain → **SSL**
- Enable "Force HTTPS" redirect

---

## 🔄 Update Workflow

### For Content Updates (Blog Posts)

**Option 1: Manual Update**
1. Edit markdown files in `/app/src/data/post/`
2. Run `npm run build`
3. Upload new `dist/` contents to server

**Option 2: Using DecapCMS**
1. Login to `https://yourdomain.com/decapcms/`
2. Create/edit posts
3. Publish (commits to Git)
4. Rebuild on server or manually trigger build

**Option 3: Automated CI/CD**
- Set up GitHub Actions to build on commit
- Auto-deploy to AAPanel server

---

## 📊 Site Structure After Deployment

```
/www/wwwroot/yourdomain.com/
├── index.html                    # Homepage
├── blog/
│   └── index.html               # Blog listing
├── advanced-seo-guide-2025/
│   └── index.html               # Sample blog post
├── seo-tools/
│   └── index.html               # SEO tools page
├── decapcms/
│   ├── index.html               # CMS admin interface
│   └── config.yml               # CMS configuration
├── _astro/                       # Optimized assets
│   ├── *.css                    # Minified CSS
│   ├── *.js                     # Minified JS
│   └── *.webp                   # Optimized images
├── sitemap-index.xml            # SEO sitemap
├── robots.txt                   # Search engine directives
└── favicon.svg                  # Site icon
```

---

## 🐛 Troubleshooting

### Issue: 404 Errors on Direct Page Access
**Solution:** Configure Nginx to handle SPA routing:
```nginx
location / {
    try_files $uri $uri/ $uri.html =404;
}
```

### Issue: Images Not Loading
**Solution:** Check image paths and permissions:
```bash
chmod -R 755 /www/wwwroot/yourdomain.com/_astro/
```

### Issue: CSS Not Applied
**Solution:** Clear browser cache and verify CSS files exist in `_astro/` directory

### Issue: DecapCMS Admin Not Accessible
**Solution:** 
1. Verify `/decapcms/index.html` exists
2. Check backend configuration in `config.yml`
3. Ensure authentication is properly configured

### Issue: Slow Loading
**Solution:**
1. Enable Gzip compression in AAPanel
2. Enable browser caching
3. Consider using CDN (Cloudflare)

---

## ⚙️ AAPanel Optimization Settings

### 1. Enable Gzip Compression
AAPanel → Website → Your Domain → **Performance** → Enable Gzip

### 2. Enable Browser Caching
Add to Nginx config:
```nginx
location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|webp)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}
```

### 3. Enable HTTP/2
AAPanel → Website → Your Domain → **SSL** → Enable HTTP/2

### 4. Set Up CDN (Optional)
- Use Cloudflare free plan
- Point DNS to Cloudflare
- Enable auto-minification
- Enable Brotli compression

---

## 📝 Maintenance Checklist

### Weekly
- [ ] Check website accessibility
- [ ] Monitor server resources in AAPanel
- [ ] Review error logs

### Monthly
- [ ] Update npm dependencies
- [ ] Rebuild and redeploy
- [ ] Run SEO audit
- [ ] Check SSL certificate expiry

### As Needed
- [ ] Create new blog posts
- [ ] Update content
- [ ] Monitor analytics
- [ ] Respond to issues

---

## 🎯 Quick Commands Reference

```bash
# Build site
npm run build

# Preview locally before deploy
npm run preview

# Create deployment archive
zip -r deployment.zip dist/

# Upload to server (from local)
scp -r dist/* root@SERVER-IP:/www/wwwroot/yourdomain.com/

# Set permissions on server
ssh root@SERVER-IP "cd /www/wwwroot/yourdomain.com && chmod -R 755 . && chown -R www:www ."
```

---

## 📞 Support Resources

- **AAPanel Forums:** https://www.aapanel.com/forum.html
- **Astro Documentation:** https://docs.astro.build/
- **DecapCMS Docs:** https://decapcms.org/docs/
- **This Project Docs:**
  - `/app/SEO_FEATURES_DOCUMENTATION.md`
  - `/app/DECAPCMS_ACCESS_GUIDE.md`
  - `/app/SSG_SSR_VERIFICATION_REPORT.md`

---

## ✅ Deployment Checklist

Before going live:
- [ ] Updated `site` URL in `astro.config.ts`
- [ ] Updated `site` URL in `src/config.yaml`
- [ ] Updated `Sitemap` URL in `robots.txt`
- [ ] Configured DecapCMS backend (if using)
- [ ] Ran `npm run build` successfully
- [ ] Created deployment archive
- [ ] Uploaded to AAPanel server
- [ ] Set correct permissions
- [ ] Configured SSL certificate
- [ ] Enabled HTTPS redirect
- [ ] Tested all major pages
- [ ] Verified sitemap accessible
- [ ] Checked Google Search Console
- [ ] Ran performance audit
- [ ] Verified structured data

---

**🎉 Your site is now ready for production deployment on AAPanel!**
