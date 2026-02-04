# TechResona - Production Deployment Instructions

## Build Information
- Build Date: $(date)
- Astro Version: 5.x
- Optimization Level: High
- Status: Production Ready

## Deployment to aaPanel

### 1. Upload Files
Upload the entire `production-build` folder to your server.

### 2. Install Dependencies
```bash
# Backend dependencies (if applicable)
cd backend
pip3 install -r requirements.txt
```

### 3. Configure Nginx
Copy the nginx configuration file to your nginx config directory:
```bash
cp nginx.conf /www/server/nginx/conf/vhost/techresona.conf
nginx -t && nginx -s reload
```

### 4. Configure Supervisor (if using backend)
```bash
cp supervisor-backend.conf /etc/supervisor/conf.d/
supervisorctl reread
supervisorctl update
supervisorctl start techresona-backend
```

### 5. Verify Deployment
- Check website is loading: https://techresona.com
- Verify all images load correctly
- Test navigation and links
- Check console for errors
- Run PageSpeed Insights

## Performance Optimizations Applied
✅ Font preloading and preconnecting
✅ Image optimization with fetchpriority
✅ Long-term caching for static assets
✅ Layout shift prevention (CLS optimization)
✅ Canonical URL configuration
✅ Compressed HTML, CSS, and JS
✅ Optimized critical rendering path

## Cache Headers Configuration
Static assets (images, fonts, CSS, JS): 1 year cache
HTML pages: 1 hour cache with revalidation

## Support
For issues or questions, contact TechResona technical team.
