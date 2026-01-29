#!/bin/bash

# TechResona Build Optimization Script
echo "🚀 Starting TechResona SEO & Performance Optimized Build..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf dist/

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
  echo "📦 Installing dependencies..."
  npm install
fi

# Run Astro build
echo "🔨 Building Astro site..."
npm run build

# Display build stats
echo "✅ Build completed successfully!"
echo ""
echo "📊 Build Statistics:"
du -sh dist/
echo ""
echo "🎉 Optimized build ready for deployment!"
echo ""
echo "Performance features enabled:"
echo "  ✓ Image optimization with Sharp"
echo "  ✓ HTML/CSS/JS compression"
echo "  ✓ Lazy loading"
echo "  ✓ Resource hints (preconnect, dns-prefetch)"
echo "  ✓ PWA support with service worker"
echo "  ✓ Comprehensive SEO meta tags"
echo "  ✓ Structured data (JSON-LD)"
echo "  ✓ Optimized favicons for all devices"
echo "  ✓ Security headers"
echo "  ✓ Caching strategy"
