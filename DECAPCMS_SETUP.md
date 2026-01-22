# 📝 DecapCMS Setup Guide for TechResona

## Overview

DecapCMS (formerly Netlify CMS) is now configured at `/admin` for managing blog posts.

## Accessing DecapCMS

### Test Mode (Current Configuration)

The CMS is currently configured in **test mode** for immediate use:

```
URL: https://your-domain.com/admin
OR: http://localhost:3000/admin (during development)
```

**Note:** In test mode:
- ✅ No authentication required
- ✅ Full CMS interface available
- ❌ Changes are NOT saved to your repository
- ❌ Only for testing the interface

## Configuration Files

### Location
- **Admin Interface:** `/app/public/admin/index.html`
- **CMS Configuration:** `/app/public/admin/config.yml`

### Current Backend Configuration

```yaml
backend:
  name: test-repo  # Test mode - no auth required
```

## Production Setup Options

### Option 1: GitHub Backend (Recommended)

For production use with Git-based workflow:

1. **Update config.yml:**
```yaml
backend:
  name: github
  repo: your-username/your-repo  # e.g., techresona/website
  branch: main
```

2. **Setup GitHub OAuth:**
   - Create OAuth App at: https://github.com/settings/developers
   - Set Authorization callback URL: `https://yourdomain.com/admin`
   - You'll need an OAuth provider service (like Netlify, Vercel, or self-hosted)

3. **Add OAuth Provider:**
   - Use Netlify Git Gateway (easiest - requires Netlify deployment)
   - Or use external provider: https://github.com/vencax/netlify-cms-github-oauth-provider

### Option 2: GitLab Backend

```yaml
backend:
  name: gitlab
  repo: your-username/your-repo
  auth_type: pkce # Recommended for GitLab
```

### Option 3: Git Gateway (via Netlify Identity)

```yaml
backend:
  name: git-gateway
  branch: main
```

Requires Netlify deployment with Identity service enabled.

## Managing Blog Posts

### Using DecapCMS Interface

1. **Navigate to Admin Panel**
   - Visit: `https://yourdomain.com/admin`
   - Or: `http://localhost:3000/admin` (dev)

2. **Create New Post**
   - Click "Blog Posts" collection
   - Click "New Blog Posts"
   - Fill in the fields:
     - **Title:** Post title (30-60 chars for SEO)
     - **Excerpt:** Brief summary
     - **Category:** Post category
     - **Tags:** Relevant tags
     - **Image:** Featured image URL
     - **Publish Date:** When to publish
     - **Author:** Author name
     - **SEO Fields:**
       - Focus Keyword
       - Meta Title
       - Meta Description
       - Keywords
     - **Content:** Main post content in Markdown

3. **Save/Publish**
   - In test mode: Preview only
   - In production: Commits to Git repository

### Manual Post Creation

Alternatively, create posts directly in `/app/src/content/post/`:

```markdown
---
title: 'Your Post Title'
excerpt: 'Brief summary of the post'
category: 'Technology'
tags:
  - web development
  - cloud
image: 'https://example.com/image.jpg'
publishDate: 2025-01-22T00:00:00.000Z
author: 'Your Name'
focusKeyword: 'cloud migration'
metaTitle: 'SEO Optimized Title'
metaDescription: 'Description for search results'
keywords: 'cloud, migration, azure'
---

# Your Post Content

Write your blog post here in Markdown format...

## Section Heading

More content...
```

## Content Structure

### Blog Post Schema

All blog posts support:

**Basic Fields:**
- Title (required)
- Excerpt (required)
- Category (required)
- Tags (list)
- Featured Image URL
- Publish Date
- Author

**SEO Fields:**
- Focus Keyword
- Meta Title (custom title for search engines)
- Meta Description (120-160 characters)
- Keywords (comma-separated)

**Content:**
- Full Markdown support
- Code blocks
- Images
- Lists
- Tables
- Links

## Media Management

### Current Setup
```yaml
media_folder: 'src/assets/images'
public_folder: '/_astro'
```

### Uploading Images

1. **Via CMS:**
   - Use the image picker widget
   - Upload images directly (saved to `src/assets/images`)

2. **Manual:**
   - Add images to `/app/src/assets/images/`
   - Reference in posts: `![Alt text](/_astro/image-name.jpg)`

3. **External URLs:**
   - Use full URLs: `https://example.com/image.jpg`

## Workflow

### Development Workflow

1. **Start dev server:**
```bash
npm run dev
```

2. **Access CMS:**
```
http://localhost:3000/admin
```

3. **Create/Edit Posts:**
   - Use CMS interface or edit markdown files directly

4. **Preview:**
   - Changes reflect immediately in dev mode

### Production Workflow (with Git Backend)

1. **Access Production CMS:**
```
https://yourdomain.com/admin
```

2. **Authenticate:**
   - Login via GitHub/GitLab OAuth

3. **Create/Edit Content:**
   - Changes are committed to Git

4. **Deploy:**
   - Trigger rebuild/deployment
   - Changes go live

## Troubleshooting

### Can't Access /admin

- **Check:** Frontend service is running
  ```bash
  sudo supervisorctl status frontend
  ```
- **Check:** Navigate to correct URL
- **Dev:** `http://localhost:3000/admin`
- **Prod:** `https://yourdomain.com/admin`

### Changes Not Saving

- **Test Mode:** Changes don't persist - this is expected
- **Solution:** Configure Git backend for production

### Authentication Issues

- **Test Mode:** No authentication needed
- **Git Backend:** Ensure OAuth is configured correctly
- **Check:** Callback URLs match exactly

### Images Not Loading

- **Check:** Image paths are correct
- **Use:** Full URLs for external images
- **Verify:** Images exist in `src/assets/images/`

## Next Steps for Production

To make DecapCMS fully functional in production:

1. **Choose Authentication Method:**
   - GitHub OAuth (recommended)
   - GitLab OAuth
   - Netlify Identity

2. **Setup OAuth Provider:**
   - Deploy OAuth proxy service
   - Or use Netlify/Vercel built-in

3. **Update Configuration:**
   - Change `backend` in `config.yml`
   - Add OAuth credentials

4. **Test Workflow:**
   - Login to CMS
   - Create test post
   - Verify Git commit
   - Check site rebuild

## Resources

- [DecapCMS Documentation](https://decapcms.org/docs/)
- [GitHub Backend Setup](https://decapcms.org/docs/github-backend/)
- [GitLab Backend Setup](https://decapcms.org/docs/gitlab-backend/)
- [Git Gateway](https://decapcms.org/docs/git-gateway-backend/)

## Support

For TechResona-specific CMS issues:
- Check `/app/public/admin/config.yml`
- Review backend logs: `tail -f /var/log/supervisor/frontend.err.log`
- Ensure all services are running: `sudo supervisorctl status`
