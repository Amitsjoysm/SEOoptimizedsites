# Contact Form Services Guide

## Overview
The TechResona website's contact form requires the following services to be running for full functionality:

## Required Services

### 1. **MongoDB** (Database)
- **Status:** ✅ RUNNING
- **Purpose:** Stores contact enquiries submitted through the form
- **Port:** 27017
- **Collection:** `techresona.enquiries`

### 2. **Backend API** (FastAPI)
- **Status:** ✅ RUNNING  
- **Purpose:** Handles form submissions and processes enquiries
- **Port:** 8001
- **Endpoint:** `/api/enquiries`
- **Health Check:** `http://localhost:8001/api/health`

### 3. **Frontend** (Astro Static Site)
- **Status:** ⚠️ NEEDS CONFIGURATION
- **Purpose:** Serves the website and contact form
- **Port:** 3000
- **Build:** Static files generated in `/app/dist/`

## Current Configuration Issues

### Issue: Backend URL Not Configured
The contact form in `/app/src/components/ui/Form.astro` tries to get the backend URL from:
```javascript
const BACKEND_URL = import.meta.env.PUBLIC_BACKEND_URL || 'https://cors-fix-sync.preview.emergentagent.com';
```

**Problem:** 
- No `PUBLIC_BACKEND_URL` environment variable is set
- Falls back to the preview URL which may not match your actual backend

## Solution: How to Enable Contact Form

### Option 1: Set Environment Variable (Recommended)

1. Create a `.env` file in `/app/` directory:
```bash
PUBLIC_BACKEND_URL=http://localhost:8001
```

2. For production, use the actual backend URL:
```bash
PUBLIC_BACKEND_URL=https://techresona.com
```

### Option 2: Update Form Component Directly

Edit `/app/src/components/ui/Form.astro` line 124:
```javascript
const BACKEND_URL = 'http://localhost:8001'; // or your production URL
```

## Service Control Commands

### Check Service Status
```bash
sudo supervisorctl status
```

### Start/Restart Services
```bash
# Restart backend
sudo supervisorctl restart backend

# Start MongoDB (usually auto-starts)
sudo supervisorctl start mongodb

# Check backend health
curl http://localhost:8001/api/health
```

### Test Contact Form Submission
```bash
curl -X POST http://localhost:8001/api/enquiries \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "+91 9876543210",
    "company": "Test Company",
    "message": "This is a test enquiry"
  }'
```

## Database Configuration

The backend connects to MongoDB using the `MONGO_URL` environment variable:
```python
MONGO_URL = os.environ.get('MONGO_URL', 'mongodb://localhost:27017')
```

This is already properly configured and working.

## Optional: Slack Notifications

The backend supports Slack notifications for new enquiries:

1. Get a Slack webhook URL from your Slack workspace
2. Set the environment variable:
```bash
export SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
```

3. Restart the backend:
```bash
sudo supervisorctl restart backend
```

## Current Service Status

```
✅ Backend API: RUNNING on port 8001
✅ MongoDB: RUNNING on port 27017  
✅ Static Site: Built successfully in /app/dist/
⚠️ Contact Form: Needs backend URL configuration
```

## How Contact Form Works

1. User fills the form on `/contact` page
2. JavaScript in `Form.astro` captures the form submission
3. Data is sent via POST request to `${BACKEND_URL}/api/enquiries`
4. Backend validates data and saves to MongoDB
5. Optional: Sends Slack notification
6. Returns success/error message to the user
7. Form displays the result and resets on success

## Troubleshooting

### Form submission fails
- Check backend is running: `curl http://localhost:8001/api/health`
- Check browser console for errors
- Verify backend URL configuration
- Check CORS settings in backend

### Data not saving
- Check MongoDB is running: `sudo supervisorctl status mongodb`
- Check backend logs: `tail -f /var/log/supervisor/backend.*.log`

### Slack notifications not working
- Verify SLACK_WEBHOOK_URL is set
- Check backend logs for Slack-related errors
- Note: Form still works without Slack configured

## Production Deployment Notes

When deploying to production:

1. Update `PUBLIC_BACKEND_URL` to production API URL
2. Rebuild the static site: `npm run build`
3. Ensure backend API is accessible from frontend domain
4. Configure proper CORS settings for production domain
5. Set up MongoDB with proper authentication
6. Configure Slack webhook for production notifications
