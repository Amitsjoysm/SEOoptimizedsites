# TechResona Website - cPanel Deployment Guide

## Production Build Information

**Build Date:** January 29, 2026  
**Build Size:** 5.2 MB  
**Total Pages:** 40+  
**Framework:** Astro 5.12.9 (Static Site Generator)

---

## What's Included

### ✅ Completed Features

1. **Theme & Branding**
   - TechResona brand colors applied (Blue #0161EF, Orange #FF6B35)
   - Custom favicon set optimized for all devices
   - Professional, modern design matching techresona.com

2. **SEO-Optimized Pages**
   - Homepage with comprehensive service overview
   - Cloud Solutions page (Azure, AWS, Managed Services)
   - Web Development page (Responsive design, WordPress, eCommerce)
   - AI & Automation page (RPA, ChatGPT integration, Power Automate)
   - SEO Services page (Local SEO, Technical SEO, Content Marketing)
   - Microsoft 365 Licenses page
   - About, Contact, Pricing pages
   - Blog with 7 articles

3. **Legal Pages**
   - Updated Terms and Conditions (TechResona Pvt Ltd specific)
   - Updated Privacy Policy (GDPR compliant, India-focused)
   - Company details: Kharadi, Pune 411047

4. **Technical SEO**
   - Sitemap (sitemap-index.xml)
   - Robots.txt configured
   - RSS feed for blog
   - Meta tags optimized
   - Open Graph tags for social sharing
   - Schema markup ready
   - Mobile responsive
   - Fast loading (optimized HTML, CSS, images)

5. **Favicon Package**
   - favicon.ico (16x16, 32x32)
   - apple-touch-icon.png (180x180)
   - android-chrome icons (192x192, 512x512)
   - site.webmanifest for PWA support
   - Theme color: #0161EF

---

## Deployment to cPanel

### Method 1: File Manager Upload (Recommended for Small Sites)

1. **Login to cPanel**
   - Navigate to your cPanel hosting dashboard
   - Go to **File Manager**

2. **Navigate to public_html**
   - Go to `public_html` directory (or your domain's root folder)
   - **IMPORTANT:** Backup existing files if any

3. **Clear Existing Files** (if updating)
   - Select all files in `public_html`
   - Delete them (or move to a backup folder)

4. **Upload Production Build**
   - Click **Upload** button
   - Upload the entire contents of `/app/dist/` folder
   - **DO NOT upload the `dist` folder itself, upload its CONTENTS**

5. **Set Permissions**
   - Select all uploaded files
   - Right-click → Change Permissions
   - Set to `644` for files, `755` for folders

6. **Test Your Site**
   - Visit your domain (e.g., techresona.com)
   - Check all pages load correctly
   - Test on mobile devices

### Method 2: FTP Upload (Recommended for Large Sites)

1. **Get FTP Credentials**
   - cPanel → FTP Accounts
   - Use your main cPanel credentials or create a new FTP account

2. **Connect via FTP Client**
   - Use FileZilla, WinSCP, or any FTP client
   - Host: ftp.yourdomain.com
   - Username: your_cpanel_username
   - Password: your_cpanel_password
   - Port: 21

3. **Upload Files**
   - Navigate to `/public_html/` on remote server
   - Backup existing files
   - Upload entire contents of `/app/dist/` folder
   - Wait for upload to complete

4. **Verify Upload**
   - Check file count matches
   - Test website functionality

### Method 3: Compress & Upload (Fastest for Many Files)

1. **Create ZIP Archive**
   ```bash
   cd /app
   cd dist
   zip -r techresona-production.zip *
   ```

2. **Upload ZIP to cPanel**
   - cPanel → File Manager → public_html
   - Upload `techresona-production.zip`
   - Right-click → Extract
   - Delete the zip file after extraction

---

## Important Files to Check

### Essential Files in dist/ folder:
```
dist/
├── index.html              # Homepage
├── 404.html               # Error page
├── robots.txt             # SEO crawling rules
├── sitemap-index.xml      # Sitemap for search engines
├── site.webmanifest       # PWA manifest
├── _astro/                # CSS, JS, images (optimized)
├── about/                 # About page
├── contact/               # Contact page
├── cloud-solutions/       # Service page
├── web-development/       # Service page
├── ai-automation/         # Service page
├── seo-services/          # Service page
├── microsoft-365-licenses/# Service page
├── pricing/               # Pricing page
├── terms/                 # Terms & Conditions
├── privacy/               # Privacy Policy
└── blog/                  # Blog articles
```

---

## Post-Deployment Checklist

### ✅ Immediate Testing
- [ ] Homepage loads correctly
- [ ] All navigation links work
- [ ] Service pages load (Cloud, Web Dev, AI, SEO, Microsoft 365)
- [ ] Contact form works (if applicable)
- [ ] Terms and Privacy pages display correctly
- [ ] Mobile responsiveness
- [ ] Favicon appears in browser tab

### ✅ SEO Setup
- [ ] Submit sitemap to Google Search Console
  - URL: https://techresona.com/sitemap-index.xml
- [ ] Submit sitemap to Bing Webmaster Tools
- [ ] Verify Google Analytics (if configured)
- [ ] Check robots.txt: https://techresona.com/robots.txt

### ✅ Performance
- [ ] Run Google PageSpeed Insights test
- [ ] Check mobile performance
- [ ] Test loading speed
- [ ] Verify HTTPS is working

### ✅ Social Media
- [ ] Test Open Graph tags (share on Facebook/LinkedIn)
- [ ] Check Twitter Card preview
- [ ] Verify social media links in footer

---

## DNS & Domain Configuration

### If Using Custom Domain

1. **Point Domain to cPanel**
   - A Record: Point to your server IP
   - CNAME for www: Point to main domain

2. **SSL Certificate**
   - cPanel → SSL/TLS → Install Let's Encrypt (Free)
   - Or use AutoSSL in cPanel
   - Force HTTPS redirect

3. **.htaccess Configuration** (Optional)
   Create `.htaccess` file in public_html:
   ```apache
   # Force HTTPS
   RewriteEngine On
   RewriteCond %{HTTPS} off
   RewriteRule ^(.*)$ https://%{HTTP_HOST%}%{REQUEST_URI} [L,R=301]

   # Remove .html extension
   RewriteCond %{REQUEST_FILENAME} !-f
   RewriteCond %{REQUEST_FILENAME} !-d
   RewriteRule ^([^\.]+)$ $1.html [NC,L]

   # Custom Error Pages
   ErrorDocument 404 /404.html
   ```

---

## Optimization Tips

### Image Optimization
- All images already optimized in build
- Served via CDN (Unpic) where possible
- WebP format support enabled

### Caching (Add to .htaccess)
```apache
# Browser Caching
<IfModule mod_expires.c>
  ExpiresActive On
  ExpiresByType image/jpg "access plus 1 year"
  ExpiresByType image/jpeg "access plus 1 year"
  ExpiresByType image/png "access plus 1 year"
  ExpiresByType image/webp "access plus 1 year"
  ExpiresByType text/css "access plus 1 month"
  ExpiresByType application/javascript "access plus 1 month"
  ExpiresByType text/html "access plus 1 day"
</IfModule>

# Gzip Compression
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/css text/javascript application/javascript
</IfModule>
```

---

## SEO Keywords Targeting

The site is optimized for the following keyword categories:

### Cloud Services Keywords
- Azure cloud solutions
- AWS cloud consulting
- Cloud migration services India
- Managed cloud services Pune
- Hybrid cloud setup
- Multi-cloud management

### Web Development Keywords
- Web design company Pune
- WordPress development India
- Responsive web design services
- eCommerce development agency
- Progressive Web App development
- Custom website development

### AI & Automation Keywords
- Business process automation
- RPA services India
- ChatGPT integration for business
- Power Automate consulting
- Workflow automation solutions
- AI-powered automation

### SEO Services Keywords
- SEO company Pune
- Local SEO services India
- Technical SEO audit
- eCommerce SEO strategy
- Content marketing services
- SEO for service businesses

### Microsoft Services Keywords
- Microsoft 365 licenses India
- Office 365 setup Pune
- Google Workspace licenses
- Microsoft 365 migration
- Office 365 consulting

---

## Troubleshooting Common Issues

### Issue: 404 Errors on Pages
**Solution:** Ensure all folders from dist/ are uploaded, not just files

### Issue: CSS/Images Not Loading
**Solution:** Check that `_astro` folder is uploaded correctly with all assets

### Issue: Homepage Blank
**Solution:** Clear browser cache, check index.html exists in root

### Issue: Slow Loading
**Solution:** Enable Gzip compression and browser caching in .htaccess

### Issue: Mobile Not Responsive
**Solution:** Verify viewport meta tag (already included in build)

---

## Maintenance & Updates

### Regular Maintenance
- Update blog content monthly
- Check for broken links quarterly
- Update service pages when offerings change
- Refresh testimonials regularly
- Monitor Google Search Console for errors

### Future Development
- Add contact form backend (currently static)
- Integrate CRM for lead capture
- Add live chat support
- Implement A/B testing
- Add customer portal

---

## Support & Contact

**Website:** https://techresona.com  
**Email:** info@techresona.com  
**Phone:** +91 7517402788  
**Address:** Kharadi, Pune 411047, Maharashtra, India

---

## Build Information

**Generated:** January 29, 2026  
**Astro Version:** 5.12.9  
**Node Version:** 20.20.0  
**Build Time:** ~15 seconds  
**Total Files:** 40+ pages  
**Total Size:** 5.2 MB

---

## Notes for Developer

- Source code available in `/app` directory
- To rebuild: `cd /app && yarn build`
- Production files output to `/app/dist/`
- Hot reload enabled for development: `yarn dev`
- Configuration: `/app/astro.config.ts`
- Content: `/app/src/config.yaml`

---

**Deployment Ready! ✅**

Your TechResona website is fully optimized and ready for production deployment on cPanel.
