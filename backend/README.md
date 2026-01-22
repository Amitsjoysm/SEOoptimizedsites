# TechResona Backend API

FastAPI backend for handling contact form submissions with MongoDB storage and Slack notifications.

## Features

- ✅ RESTful API endpoints for enquiries
- ✅ MongoDB database integration
- ✅ Slack webhook notifications
- ✅ Form validation with Pydantic
- ✅ CORS enabled for frontend integration
- ✅ Health check endpoint

## API Endpoints

### Health Check
```bash
GET /api/health
```
Returns the health status of the API, database connection, and Slack configuration.

### Create Enquiry
```bash
POST /api/enquiries
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+91 9876543210",
  "company": "Acme Corp",
  "message": "I need help with cloud migration"
}
```

### List All Enquiries
```bash
GET /api/enquiries?skip=0&limit=50
```

### Get Single Enquiry
```bash
GET /api/enquiries/{enquiry_id}
```

## Environment Variables

- `MONGO_URL`: MongoDB connection string (default: mongodb://localhost:27017)
- `SLACK_WEBHOOK_URL`: Slack webhook URL for notifications

## Local Development

```bash
cd /app/backend
pip install -r requirements.txt
uvicorn server:app --reload --host 0.0.0.0 --port 8001
```

## Testing

```bash
# Test health endpoint
curl http://localhost:8001/api/health

# Submit test enquiry
curl -X POST http://localhost:8001/api/enquiries \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "phone": "+91 9876543210",
    "company": "Test Co",
    "message": "Test message"
  }'
```

## Slack Notifications

When an enquiry is submitted, a formatted message is sent to the configured Slack channel with:
- Customer name
- Email
- Phone number
- Company name
- Message content
- Submission timestamp

## Database Schema

### Enquiry Document
```json
{
  "_id": "ObjectId",
  "name": "string",
  "email": "string",
  "phone": "string",
  "company": "string",
  "message": "string",
  "created_at": "ISO datetime string",
  "status": "new",
  "source": "website_contact_form"
}
```

## Production Deployment

The backend runs via supervisor on port 8001. Configuration in `/etc/supervisor/conf.d/supervisord.conf`.

Restart backend:
```bash
sudo supervisorctl restart backend
```

View logs:
```bash
tail -f /var/log/supervisor/backend.err.log
```
