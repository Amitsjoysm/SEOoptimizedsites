# 🔐 DecapCMS Access Guide for AAPanel Deployment

## 📋 Overview

DecapCMS provides a user-friendly admin interface for managing blog content. For AAPanel-hosted sites, we'll set up multiple authentication options.

---

## 🚀 Quick Start: Local Development Mode

For **immediate testing without authentication**, use local backend:

### 1. Update DecapCMS Config for Local Development

The config is already set up, but to use locally:

```bash
# Run development server
npm run dev

# Access admin panel at:
http://localhost:4321/decapcms/
```

**Note:** Local backend only works during development (npm run dev), not on production builds.

---

## 🌐 Production Setup Options

### Option 1: GitHub OAuth (Recommended for AAPanel)

This is the best option for self-hosted sites on AAPanel.

#### Step 1: Create GitHub OAuth App

1. Go to GitHub → Settings → Developer settings → OAuth Apps
2. Click "New OAuth App"
3. Fill in details:
   - **Application name:** Your Site Name CMS
   - **Homepage URL:** https://yoursite.com
   - **Authorization callback URL:** https://yoursite.com/decapcms/
4. Click "Register application"
5. Save your **Client ID**
6. Generate a new **Client Secret** and save it

#### Step 2: Set Up Serverless Function

You need a serverless function to handle OAuth. Two options:

**Option A: Use Netlify Functions (Easiest)**
- Deploy your site to Netlify
- Use their built-in Git Gateway (automatic)

**Option B: Use External Auth Service**
- Use [netlify-cms-oauth-provider-node](https://github.com/vencax/netlify-cms-github-oauth-provider)
- Deploy on Vercel/Railway/your server
- Point to this service in config

#### Step 3: Update DecapCMS Config

Update `/app/public/decapcms/config.yml`:

```yaml
backend:
  name: github
  repo: YOUR_USERNAME/YOUR_REPO_NAME  # e.g., johndoe/my-website
  branch: main
  base_url: https://your-oauth-service.com  # If using external OAuth
```

---

### Option 2: Test Mode (No Authentication)

For **testing only**, you can use test backend:

Update `/app/public/decapcms/config.yml`:

```yaml
backend:
  name: test-repo
```

**Warning:** This only works for testing. Changes won't be saved!

---

### Option 3: Manual Git Workflow (No CMS Auth Needed)

Simply create markdown files manually in `/app/src/data/post/` and commit to Git.

---

## 📝 How to Create Blog Posts

### Method 1: Using DecapCMS Admin Panel

1. **Access Admin Panel**
   ```
   https://yoursite.com/decapcms/
   ```

2. **Login** (if authentication is configured)

3. **Create New Post**
   - Click "New Post" button
   - Fill in the form:

   **Basic Fields:**
   - Title: Your post title (30-60 characters recommended)
   - Excerpt: Brief summary
   - Category: Select or create category
   - Tags: Add relevant tags
   - Image: Enter image URL or upload
   - Publish Date: Set publish date/time
   - Author: Your name

   **SEO Fields:**
   - Focus Keyword: Main keyword (e.g., "web development tips")
   - Meta Title: Custom title for search results (optional)
   - Meta Description: 120-160 characters for search results
   - Keywords: Comma-separated keywords

   **Content:**
   - Write your post in markdown format
   - Use the visual editor or raw markdown mode

4. **Preview** (optional)
   - Click "Preview" to see how it looks

5. **Publish**
   - Click "Publish" to save
   - Changes will be committed to your Git repository

6. **Rebuild Site**
   - After publishing, rebuild your site:
   ```bash
   npm run build
   ```

### Method 2: Manual File Creation

Create a file in `/app/src/data/post/my-new-post.md`:

```markdown
---
publishDate: 2025-01-21T00:00:00Z
title: 'Your Post Title Here'
excerpt: 'Brief summary of your post'
image: 'https://your-image-url.com/image.jpg'
category: 'Technology'
tags:
  - web development
  - tutorial
author: 'Your Name'

# SEO Fields
focusKeyword: 'main keyword'
metaTitle: 'Custom SEO Title'
metaDescription: 'Description for search results between 120-160 characters.'
keywords: 'keyword1, keyword2, keyword3'
---

# Your Post Content Here

Write your blog post content in markdown...

## Section Heading

More content...
```

---

## 🔧 For AAPanel Deployment

I'll now create a production-ready build specifically for AAPanel hosting.

---

## 📦 Default Credentials

**Important:** DecapCMS doesn't use username/password by default. It uses:
- **GitHub OAuth** - Uses your GitHub account
- **Netlify Identity** - Requires Netlify account
- **Test Mode** - No login required (testing only)

---

## 🎯 Recommended Setup for AAPanel

Since you're hosting on AAPanel (self-hosted), here's the recommended workflow:

### Easiest Workflow:
1. **Development:** Create posts manually in markdown files
2. **Build:** Run `npm run build` to generate static files
3. **Deploy:** Upload `dist/` folder to AAPanel
4. **CMS Access:** Use GitHub + Netlify CMS OAuth (requires external OAuth service)

### Alternative Workflow:
1. **Use Git-based workflow** - No CMS login needed
2. **Edit markdown files** directly in your repository
3. **Automatic builds** via GitHub Actions or manual builds
4. **Upload to AAPanel**

---

## 🆘 Quick Test Without Authentication

To test DecapCMS immediately without any authentication:

1. During development only:
```bash
npm run dev
# Access: http://localhost:4321/decapcms/
```

2. For production testing, update config to use test-repo backend (changes won't persist)

---

## 📞 Need Help?

- [DecapCMS Documentation](https://decapcms.org/docs/)
- [GitHub OAuth Setup Guide](https://decapcms.org/docs/github-backend/)
- [AAPanel Documentation](https://www.aapanel.com/reference.html)
