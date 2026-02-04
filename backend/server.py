from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, validator
from motor.motor_asyncio import AsyncIOMotorClient
from datetime import datetime
import os
import httpx
from typing import Optional
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

app = FastAPI(title="TechResona API")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# MongoDB setup
MONGO_URL = os.environ.get('MONGO_URL', 'mongodb://localhost:27017')
client = AsyncIOMotorClient(MONGO_URL)
db = client.techresona
enquiries_collection = db.enquiries

# Slack webhook URL
SLACK_WEBHOOK_URL = os.environ.get('SLACK_WEBHOOK_URL', '')

# Pydantic models
class EnquiryRequest(BaseModel):
    name: str
    email: EmailStr
    phone: str
    company: Optional[str] = None
    message: str
    
    @validator('name')
    def validate_name(cls, v):
        if not v or len(v.strip()) < 2:
            raise ValueError('Name must be at least 2 characters long')
        return v.strip()
    
    @validator('phone')
    def validate_phone(cls, v):
        if not v or len(v.strip()) < 10:
            raise ValueError('Please provide a valid phone number')
        return v.strip()
    
    @validator('message')
    def validate_message(cls, v):
        if not v or len(v.strip()) < 10:
            raise ValueError('Message must be at least 10 characters long')
        return v.strip()

class EnquiryResponse(BaseModel):
    success: bool
    message: str
    enquiry_id: Optional[str] = None

# Helper function to send Slack notification
async def send_slack_notification(enquiry_data: dict):
    """Send notification to Slack when a new enquiry is received"""
    if not SLACK_WEBHOOK_URL:
        print("Warning: SLACK_WEBHOOK_URL not configured")
        return False
    
    try:
        # Format the Slack message with rich formatting
        slack_message = {
            "blocks": [
                {
                    "type": "header",
                    "text": {
                        "type": "plain_text",
                        "text": "🎯 New Enquiry Received!",
                        "emoji": True
                    }
                },
                {
                    "type": "section",
                    "fields": [
                        {
                            "type": "mrkdwn",
                            "text": f"*Name:*\n{enquiry_data['name']}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Email:*\n{enquiry_data['email']}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Phone:*\n{enquiry_data['phone']}"
                        },
                        {
                            "type": "mrkdwn",
                            "text": f"*Company:*\n{enquiry_data.get('company', 'Not provided')}"
                        }
                    ]
                },
                {
                    "type": "section",
                    "text": {
                        "type": "mrkdwn",
                        "text": f"*Message:*\n{enquiry_data['message']}"
                    }
                },
                {
                    "type": "context",
                    "elements": [
                        {
                            "type": "mrkdwn",
                            "text": f"📅 Submitted: {enquiry_data['created_at']}"
                        }
                    ]
                },
                {
                    "type": "divider"
                }
            ]
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                SLACK_WEBHOOK_URL,
                json=slack_message,
                timeout=10.0
            )
            return response.status_code == 200
    except Exception as e:
        print(f"Error sending Slack notification: {e}")
        return False

@app.get("/")
async def root():
    return {"message": "TechResona API is running", "status": "healthy"}

@app.get("/api/health")
async def health_check():
    try:
        # Check MongoDB connection
        await db.command('ping')
        return {
            "status": "healthy",
            "database": "connected",
            "slack_configured": bool(SLACK_WEBHOOK_URL)
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {str(e)}")

@app.post("/api/enquiries", response_model=EnquiryResponse)
async def create_enquiry(enquiry: EnquiryRequest):
    """
    Create a new enquiry from the contact form.
    Saves to MongoDB and sends Slack notification.
    """
    try:
        # Prepare enquiry data
        enquiry_data = {
            "name": enquiry.name,
            "email": enquiry.email,
            "phone": enquiry.phone,
            "company": enquiry.company,
            "message": enquiry.message,
            "created_at": datetime.utcnow().isoformat(),
            "status": "new",
            "source": "website_contact_form"
        }
        
        # Save to MongoDB
        result = await enquiries_collection.insert_one(enquiry_data)
        enquiry_id = str(result.inserted_id)
        
        # Send Slack notification (non-blocking)
        slack_sent = await send_slack_notification(enquiry_data)
        
        return EnquiryResponse(
            success=True,
            message="Thank you for your enquiry! We'll get back to you within 24 hours.",
            enquiry_id=enquiry_id
        )
    
    except Exception as e:
        print(f"Error creating enquiry: {e}")
        raise HTTPException(
            status_code=500,
            detail="Failed to submit enquiry. Please try again or contact us directly."
        )

@app.get("/api/enquiries")
async def list_enquiries(skip: int = 0, limit: int = 50):
    """
    List all enquiries (admin endpoint - should be protected in production)
    """
    try:
        cursor = enquiries_collection.find().sort("created_at", -1).skip(skip).limit(limit)
        enquiries = await cursor.to_list(length=limit)
        
        # Convert ObjectId to string
        for enquiry in enquiries:
            enquiry['_id'] = str(enquiry['_id'])
        
        total = await enquiries_collection.count_documents({})
        
        return {
            "total": total,
            "enquiries": enquiries,
            "skip": skip,
            "limit": limit
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/enquiries/{enquiry_id}")
async def get_enquiry(enquiry_id: str):
    """
    Get a specific enquiry by ID
    """
    try:
        from bson import ObjectId
        enquiry = await enquiries_collection.find_one({"_id": ObjectId(enquiry_id)})
        
        if not enquiry:
            raise HTTPException(status_code=404, detail="Enquiry not found")
        
        enquiry['_id'] = str(enquiry['_id'])
        return enquiry
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8001)
