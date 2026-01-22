# 🔧 DecapCMS - Why It's Not Working & How to Fix It

## Current Status: ⚠️ TEST MODE ONLY

DecapCMS is **installed and accessible** but configured in **test mode**, which means:

✅ **What Works:**
- CMS admin interface is accessible
- You can create and edit posts in the UI
- All form fields and features are functional
- No authentication required

❌ **What Doesn't Work:**
- **Changes are NOT saved to your repository**
- Posts created in test mode won't appear on your site
- It's only for testing the interface
- No Git integration

## 🌐 How to Access DecapCMS

### Development:
```
http://localhost:3000/admin
```

### Production:
```
https://your-domain.com/admin
```

## 🔍 Why Changes Don't Save

The current configuration in `/app/public/admin/config.yml`:

```yaml
backend:
  name: test-repo  # ⚠️ This is test mode
```

**Test mode is intentional** because proper setup requires:
1. A Git repository (GitHub/GitLab)
2. OAuth authentication setup
3. An OAuth provider service

## 🚀 How to Make DecapCMS Fully Functional

### Option 1: GitHub Backend (Recommended)

**Step 1: Update Configuration**

Edit `/app/public/admin/config.yml`:

```yaml
backend:
  name: github
  repo: your-username/techresona-website  # Replace with your repo
  branch: main
```

**Step 2: Create GitHub OAuth App**

1. Go to: https://github.com/settings/developers
2. Click "New OAuth App"
3. Fill in:
   - **Application name:** TechResona CMS
   - **Homepage URL:** `https://yourdomain.com`
   - **Authorization callback URL:** `https://yourdomain.com/admin/`
4. Save **Client ID** and **Client Secret**

**Step 3: Setup OAuth Provider**

You need an OAuth provider service. Choose one:

**A) Using Netlify (Easiest):**
- Deploy your site to Netlify
- Enable Netlify Identity
- Enable Git Gateway in Netlify dashboard
- Update config to use `git-gateway` backend

**B) Self-hosted OAuth Provider:**
```bash
# Use this project: https://github.com/vencax/netlify-cms-github-oauth-provider
git clone https://github.com/vencax/netlify-cms-github-oauth-provider
cd netlify-cms-github-oauth-provider

# Configure with your GitHub OAuth credentials
# Deploy to Heroku, Railway, or your server

# Then update config.yml:
backend:
  name: github
  repo: your-username/repo
  branch: main
  base_url: https://your-oauth-provider.com
```

**C) Using Vercel/Railway:**
Deploy the OAuth provider to Vercel or Railway and configure accordingly.

### Option 2: GitLab Backend

Edit `/app/public/admin/config.yml`:

```yaml
backend:
  name: gitlab
  repo: your-username/techresona-website
  auth_type: pkce  # Recommended
```

Similar OAuth setup required.

### Option 3: Keep Test Mode (Quick Testing)

If you just want to test the interface without saving:
- Current setup works fine
- No additional configuration needed
- Perfect for previewing CMS features

## 📝 Alternative: Manual Blog Management

If you don't need the CMS interface, you can manage blog posts manually:

**Create a file:** `/app/src/content/post/my-blog-post.md`

```markdown
---
publishDate: 2025-01-22T00:00:00Z
title: 'My Blog Post Title'
excerpt: 'Brief summary of the post'
image: 'https://example.com/image.jpg'
category: 'Technology'
tags:
  - web development
  - cloud
author: 'Your Name'
focusKeyword: 'cloud migration'
metaTitle: 'SEO Title'
metaDescription: 'SEO description for search engines'
keywords: 'cloud, migration, azure'
---

# Your Post Content

Write your blog post here...

## Section Heading

More content...
```

Then rebuild:
```bash
npm run build
```

## ✅ Quick Checklist

### To Make DecapCMS Work in Production:

- [ ] Have a Git repository (GitHub/GitLab)
- [ ] Create OAuth application on GitHub/GitLab
- [ ] Deploy OAuth provider service (or use Netlify)
- [ ] Update `/app/public/admin/config.yml` with correct backend
- [ ] Add OAuth credentials to your deployment
- [ ] Test login and post creation
- [ ] Verify Git commits are created

### Current Setup (Test Mode):

- [x] Admin interface accessible at `/admin`
- [x] All CMS features visible
- [x] No authentication required
- [ ] Git integration (not configured)
- [ ] Changes persist (not available in test mode)

## 🎯 Recommended Workflow

### For Immediate Use:
1. **Use manual blog post creation** (create `.md` files)
2. This works immediately without any additional setup
3. Full control over content
4. No authentication needed

### For CMS Interface:
1. **Deploy to Netlify** (simplest option)
2. Enable Netlify Identity + Git Gateway
3. Update config to use `git-gateway`
4. Full CMS functionality with minimal setup

### For Self-Hosted:
1. Keep current hosting
2. Deploy OAuth provider separately
3. Configure GitHub backend with OAuth
4. More setup but full control

## 🔗 Resources

- **DecapCMS Docs:** https://decapcms.org/docs/
- **GitHub Backend:** https://decapcms.org/docs/github-backend/
- **Git Gateway:** https://decapcms.org/docs/git-gateway-backend/
- **OAuth Provider:** https://github.com/vencax/netlify-cms-github-oauth-provider
- **Test Mode Info:** https://decapcms.org/docs/test-backend/

## 💡 Summary

**Why DecapCMS "Doesn't Work":**
- It's in test mode by design
- Full functionality requires Git + OAuth setup
- This is standard for DecapCMS, not an error

**Solution:**
- For **testing interface:** Current setup is fine
- For **production use:** Configure Git backend + OAuth
- For **immediate blogging:** Use manual markdown files (works now!)

**Current Status:**
✅ Interface: Working
✅ Forms: Working
✅ Preview: Working
⏳ Git Integration: Requires configuration
⏳ Persistence: Requires Git backend

The CMS is **ready to use** once you complete the authentication setup, or you can continue using manual markdown files which work perfectly without any additional configuration!
