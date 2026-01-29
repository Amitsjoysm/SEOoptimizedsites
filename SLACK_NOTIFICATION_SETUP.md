# Slack Notification Setup Guide

## Overview

The TechResona backend has integrated Slack notification functionality. When a new enquiry is submitted through the contact form, a formatted notification is automatically sent to your configured Slack channel.

## Setup Instructions

### 1. Create a Slack Incoming Webhook

1. Go to your Slack workspace
2. Navigate to **Apps** → **Add Apps**
3. Search for "Incoming Webhooks" and add it to your workspace
4. Select the channel where you want to receive notifications
5. Copy the generated Webhook URL (it looks like: `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXX`)

### 2. Configure Backend Environment

Add the Slack Webhook URL to your backend environment file:

```bash
# /app/backend/.env
MONGO_URL=mongodb://localhost:27017
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
```

### 3. Restart Backend Service

After adding the webhook URL, restart the backend:

```bash
sudo supervisorctl restart backend
```

## Testing Slack Notifications

### Test via API

```bash
curl -X POST http://localhost:8001/api/enquiries \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "+1234567890",
    "company": "Test Company",
    "message": "This is a test enquiry."
  }'
```

### Verify Configuration

Check if Slack is configured:

```bash
curl http://localhost:8001/api/health
```

Expected response:
```json
{
  "status": "healthy",
  "database": "connected",
  "slack_configured": true
}
```

## Notification Format

When an enquiry is received, Slack will show a rich formatted message with:

- **Header**: "🎯 New Enquiry Received!"
- **Fields**: Name, Email, Phone, Company
- **Message**: Full enquiry message
- **Timestamp**: Submission time

## Features

✅ **Automatic Notifications**: Instant alerts when enquiries are submitted
✅ **Rich Formatting**: Beautiful Slack blocks with emojis and structured data
✅ **Non-Blocking**: Notifications are sent asynchronously without affecting API response time
✅ **Error Handling**: Graceful fallback if Slack webhook fails
✅ **Database Backup**: All enquiries are stored in MongoDB regardless of Slack status

## Troubleshooting

### Notifications Not Sending

1. Verify webhook URL is correct in `.env`
2. Check backend logs: `tail -f /var/log/supervisor/backend.err.log`
3. Ensure webhook URL has proper permissions
4. Test webhook manually using curl

### Backend Not Starting

1. Check for syntax errors in `.env`
2. Verify MongoDB is running: `sudo supervisorctl status mongodb`
3. Check backend logs for specific errors

## API Endpoints

### Create Enquiry
- **Endpoint**: `POST /api/enquiries`
- **Triggers**: Slack notification (if configured)
- **Returns**: Success message and enquiry ID

### List Enquiries
- **Endpoint**: `GET /api/enquiries`
- **Purpose**: View all submitted enquiries
- **Auth**: Should be protected in production

### Health Check
- **Endpoint**: `GET /api/health`
- **Purpose**: Check service status and Slack configuration

## Security Notes

🔒 **Important**: In production environments:
- Protect admin endpoints with authentication
- Use HTTPS for all API calls
- Keep webhook URL secret and don't commit to version control
- Implement rate limiting for the enquiry endpoint
- Add CAPTCHA to prevent spam submissions

## Support

For issues or questions:
- Check application logs
- Verify environment configuration
- Test individual components (MongoDB, Backend, Slack webhook)
- Review Slack webhook permissions

---

**Last Updated**: January 29, 2025
