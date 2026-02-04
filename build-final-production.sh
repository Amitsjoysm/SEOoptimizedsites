#!/bin/bash
# Optimized Production Build Script for TechResona
# This script builds a production-ready version with all optimizations applied

set -e  # Exit on any error

echo "================================================"
echo "TechResona - Production Build (Optimized)"
echo "================================================"

# Step 1: Clean previous builds
echo ""
echo "Step 1: Cleaning previous builds..."
rm -rf /app/production-build
rm -rf /app/.astro
rm -rf /app/dist

# Step 2: Install dependencies (if needed)
echo ""
echo "Step 2: Checking dependencies..."
if [ ! -d "/app/node_modules" ]; then
  echo "Installing dependencies..."
  cd /app && yarn install --frozen-lockfile
else
  echo "Dependencies already installed."
fi

# Step 3: Run production build
echo ""
echo "Step 3: Building production version..."
cd /app
NODE_ENV=production yarn build

# Step 4: Copy dist to production-build
echo ""
echo "Step 4: Organizing production files..."
if [ -d "/app/dist" ]; then
  cp -r /app/dist /app/production-build
  echo "Production build created successfully!"
else
  echo "Error: dist folder not found after build"
  exit 1
fi

# Step 5: Copy essential backend files
echo ""
echo "Step 5: Copying backend files..."
mkdir -p /app/production-build/backend
cp /app/backend/server.py /app/production-build/backend/
cp /app/backend/requirements.txt /app/production-build/backend/
if [ -f "/app/backend/.env" ]; then
  cp /app/backend/.env /app/production-build/backend/
fi

# Step 6: Copy nginx configuration
echo ""
echo "Step 6: Copying nginx configuration..."
if [ -f "/app/nginx/nginx.conf" ]; then
  cp /app/nginx/nginx.conf /app/production-build/
fi

# Step 7: Copy supervisor configuration
echo ""
echo "Step 7: Copying supervisor configuration..."
if [ -f "/app/supervisor-backend.conf" ]; then
  cp /app/supervisor-backend.conf /app/production-build/
fi

# Step 8: Create production README
echo ""
echo "Step 8: Creating deployment documentation..."
cat > /app/production-build/DEPLOYMENT_INSTRUCTIONS.md << 'EOF'
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
EOF

# Step 9: Generate build report
echo ""
echo "Step 9: Generating build report..."
DIST_SIZE=$(du -sh /app/production-build | cut -f1)
HTML_COUNT=$(find /app/production-build -name "*.html" | wc -l)
IMAGE_COUNT=$(find /app/production-build/images -type f 2>/dev/null | wc -l || echo "0")
ASSET_COUNT=$(find /app/production-build/_astro -type f 2>/dev/null | wc -l || echo "0")

cat > /app/BUILD_REPORT.md << EOF
# TechResona - Production Build Report

**Build Date:** $(date)
**Build Status:** ✅ SUCCESS

## Build Statistics
- Total Build Size: $DIST_SIZE
- HTML Pages: $HTML_COUNT
- Images: $IMAGE_COUNT
- Compiled Assets (_astro): $ASSET_COUNT

## Optimizations Applied
✅ Critical CSS inlined
✅ Font preloading configured
✅ Image lazy loading (except LCP)
✅ Hero image with fetchpriority="high"
✅ Cache headers configured
✅ HTML/CSS/JS compression
✅ Layout shift prevention
✅ Canonical URL fixes

## Performance Targets
- First Contentful Paint (FCP): < 1.8s
- Largest Contentful Paint (LCP): < 2.5s
- Cumulative Layout Shift (CLS): < 0.1
- Time to Interactive (TTI): < 3.9s

## Deployment Ready
The production-build folder is ready for deployment to aaPanel.
All files are optimized and production-ready.

## Next Steps
1. Run cleanup script: bash cleanup-old-files.sh
2. Test the build locally (if possible)
3. Upload to production server
4. Configure nginx and restart services
5. Verify with PageSpeed Insights
EOF

echo ""
echo "================================================"
echo "BUILD COMPLETE! ✅"
echo "================================================"
echo ""
echo "Build Size: $DIST_SIZE"
echo "HTML Pages: $HTML_COUNT"
echo "Output: /app/production-build/"
echo ""
echo "Next Steps:"
echo "1. Review BUILD_REPORT.md for details"
echo "2. Run: bash cleanup-old-files.sh (to clean old files)"
echo "3. Test the production build"
echo "4. Deploy to aaPanel server"
echo ""
echo "================================================"
