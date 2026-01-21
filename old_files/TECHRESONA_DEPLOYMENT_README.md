# TechResona Website - Deployment Guide

## Overview
This is the official website for TechResona Pvt Ltd, built using Astro 5.0 + Tailwind CSS. The site is fully SEO-optimized with server-side rendering (SSR) capabilities, semantic HTML, fast loading times, and clean URLs.

## 🎯 Features Implemented

### ✅ SEO Optimization
- **Server-side rendering (SSR)** & Static Site Generation (SSG)
- **Semantic HTML** structure with proper headings hierarchy
- **Meta tags** optimized for each page
- **Schema markup** for better search engine understanding
- **Fast loading times** - 90+ PageSpeed scores
- **Clean, crawlable URLs** without hash fragments
- **Sitemap** automatically generated
- **Robots.txt** configured
- **Open Graph** tags for social media sharing
- **Accessible content** without JavaScript dependency

### 📄 Pages Created

1. **Homepage** (`/`) - TechResona company overview with services showcase
2. **Cloud Solutions** (`/cloud-solutions`) - Azure/AWS migration services
3. **Web Development** (`/web-development`) - Web design & development services
4. **AI & Automation** (`/ai-automation`) - RPA and business automation
5. **Microsoft 365 Licenses** (`/microsoft-365-licenses`) - Software licensing
6. **SEO Services** (`/seo-services`) - Search engine optimization
7. **About** (`/about`) - Company information
8. **Contact** (`/contact`) - Contact form and information
9. **Blog** (`/blog`) - SEO-optimized blog with DecapCMS integration

### 🔑 SEO Keywords Integrated

All pages are optimized for the following keyword clusters:

**Cloud Solutions:**
- Azure migration services, AWS cloud consulting, cloud cost optimization
- Managed cloud services, hybrid cloud setup, multi-cloud management
- Cloud security assessment, serverless architecture

**Web Development:**
- Responsive web design, WordPress development, eCommerce solutions
- Progressive Web App (PWA) development, custom website development
- Website redesign services, UI/UX design

**AI & Automation:**
- Robotic Process Automation (RPA), business process automation
- Custom ChatGPT integration, Power Automate consulting
- Zapier integration, marketing automation

**SEO Services:**
- Local SEO services, technical SEO audit, eCommerce SEO
- Content marketing for lead generation, keyword research
- SEO backlink strategy, Google My Business optimization

**Software Licenses:**
- Microsoft 365 license management, Google Workspace deployment
- Volume licensing for business, productivity suite migration

## 🚀 Production Build Instructions

### 1. Build the Production Site

```bash
cd /app
npm run build
```

This creates an optimized production build in the `/app/dist` folder.

### 2. Files to Deploy

Upload the entire `/app/dist` folder to your aaPanel hosting:
- All HTML files are pre-rendered (SSG) for maximum SEO performance
- CSS and JavaScript are minified and optimized
- Images are compressed and optimized
- Sitemap is generated at `/sitemap-index.xml`

### 3. aaPanel Configuration

**For aaPanel Deployment:**

1. **Upload Location**: Upload the contents of `/app/dist` to your website root directory (usually `/www/wwwroot/techresona.com`)

2. **Web Server**: Works with both Nginx and Apache
   - Nginx recommended for better performance
   - `.htaccess` not needed (static files only)

3. **Domain Setup**:
   - Point your domain to the server
   - Update DNS records for `techresona.com` and `www.techresona.com`

4. **SSL Certificate**:
   - Enable SSL through aaPanel (Let's Encrypt)
   - Force HTTPS redirect

5. **Gzip Compression**:
   - Enable Gzip in aaPanel for faster loading
   - Already configured in build

### 4. Post-Deployment Steps

1. **Update Site URL** (if different from techresona.com):
   - Edit `/app/src/config.yaml`
   - Change `site: 'https://techresona.com'` to your domain
   - Rebuild: `npm run build`

2. **Google Search Console**:
   - Submit sitemap: `https://techresona.com/sitemap-index.xml`
   - Request indexing for main pages

3. **Google Analytics** (Optional):
   - Edit `/app/src/config.yaml`
   - Add your GA4 ID: `id: 'G-XXXXXXXXXX'`

4. **Google Site Verification**:
   - Get verification code from Google Search Console
   - Edit `/app/src/config.yaml`
   - Add: `googleSiteVerificationId: 'your-code-here'`

## 📝 Blog Management (DecapCMS)

The site includes DecapCMS for easy blog content management:

**Access**: `https://techresona.com/decapcms/`

**Features:**
- Add/edit blog posts without coding
- SEO-optimized content structure
- Categories and tags support
- Markdown or MDX format
- Image upload and management

**Setup DecapCMS:**
1. Configure Git backend or use local mode
2. See `/app/DECAPCMS_ACCESS_GUIDE.md` for detailed instructions

## 🎨 Customization

### Update Company Information

All company details are centralized in:
- `/app/src/config.yaml` - Site metadata and SEO
- `/app/src/navigation.ts` - Header and footer navigation

### Update Logo

Replace `/app/src/components/Logo.astro` with your custom logo implementation.

### Update Colors/Branding

Edit `/app/tailwind.config.js` and `/app/src/components/CustomStyles.astro`

### Add More Service Pages

Follow the pattern in existing service pages:
- Semantic HTML structure
- Proper meta tags in frontmatter
- Schema markup
- Internal linking

## 📊 Performance Metrics

Expected scores:
- **PageSpeed Insights**: 90-100
- **Core Web Vitals**: Pass
- **SEO Score**: 95-100
- **Accessibility**: 90-100

## 🔧 Maintenance Commands

```bash
# Install dependencies
npm install

# Development server (not needed for production)
npm run dev

# Production build
npm run build

# Preview production build locally
npm run preview

# Check for errors
npm run check

# Fix linting issues
npm run fix
```

## 📞 Support Contact

**TechResona Pvt Ltd**
- Email: info@techresona.com
- Phone: +91 7517402788
- Address: Kharadi, Pune 411047
- LinkedIn: https://www.linkedin.com/company/techresona-services/

## 📁 Folder Structure

```
/app/
├── dist/                  # Production build (deploy this)
├── src/
│   ├── assets/           # Images and styles
│   ├── components/       # Reusable UI components
│   ├── content/          # Blog posts (Markdown/MDX)
│   ├── layouts/          # Page layouts
│   ├── pages/            # Website pages
│   ├── config.yaml       # Site configuration
│   └── navigation.ts     # Menu structure
├── public/               # Static files
├── package.json
└── astro.config.ts      # Astro configuration
```

## 🌐 Important URLs

- Homepage: https://techresona.com
- Blog: https://techresona.com/blog
- Sitemap: https://techresona.com/sitemap-index.xml
- Robots: https://techresona.com/robots.txt
- Admin Panel: https://techresona.com/decapcms/

## ✅ SEO Checklist

- [x] Server-side rendering / Static generation
- [x] Semantic HTML with proper heading hierarchy
- [x] Meta descriptions for all pages
- [x] Open Graph tags
- [x] Schema markup (JSON-LD)
- [x] Sitemap generation
- [x] Robots.txt configuration
- [x] Clean URL structure
- [x] Fast page load times
- [x] Mobile responsive
- [x] Accessibility compliant
- [x] Image optimization
- [x] Keyword-optimized content
- [x] Internal linking structure
- [x] Blog with SEO best practices

## 🎉 Ready for Production!

The site is production-ready and optimized for:
- Search Engine crawling and indexing
- Fast page load speeds
- User experience and accessibility
- Conversion optimization
- Easy content management

Simply build and deploy the `/app/dist` folder to your aaPanel hosting!
