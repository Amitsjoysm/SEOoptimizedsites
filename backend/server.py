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
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = FastAPI(title="TechResona API")

# CORS configuration - Only allow requests from techresona.com
ALLOWED_ORIGINS = [
    "https://techresona.com",
    "https://www.techresona.com",
    "http://localhost:3000",  # For local development
    "http://localhost:4321",  # For Astro dev server
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["POST", "GET", "OPTIONS"],
    allow_headers=["Content-Type", "Accept"],
)

# MongoDB setup - Optional with graceful degradation
MONGO_URL = os.environ.get('MONGO_URL', '')
client = None
db = None
enquiries_collection = None

if MONGO_URL:
    try:
        client = AsyncIOMotorClient(MONGO_URL)
        db = client.techresona
        enquiries_collection = db.enquiries
        print("✅ MongoDB connected successfully")
    except Exception as e:
        print(f"⚠️  MongoDB connection failed: {e}")
        print("ℹ️  Running without database - enquiries will be logged only")
else:
    print("ℹ️  No MONGO_URL provided - running without database")

# Slack webhook URL
SLACK_WEBHOOK_URL = os.environ.get('SLACK_WEBHOOK_URL', '')

# Email configuration
SMTP_HOST = os.environ.get('SMTP_HOST', 'smtp.gmail.com')
SMTP_PORT = int(os.environ.get('SMTP_PORT', '587'))
SMTP_USER = os.environ.get('SMTP_USER', '')
SMTP_PASSWORD = os.environ.get('SMTP_PASSWORD', '')
SMTP_FROM_EMAIL = os.environ.get('SMTP_FROM_EMAIL', '')
SMTP_TO_EMAIL = os.environ.get('SMTP_TO_EMAIL', 'info@techresona.com')

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

# Helper function to send email notification
async def send_email_notification(enquiry_data: dict):
    """Send email notification when a new enquiry is received"""
    if not all([SMTP_USER, SMTP_PASSWORD, SMTP_HOST]):
        print("Warning: SMTP configuration incomplete")
        return False
    
    try:
        # Create email message
        msg = MIMEMultipart('alternative')
        msg['Subject'] = f"🎯 New Enquiry from {enquiry_data['name']}"
        msg['From'] = SMTP_FROM_EMAIL
        msg['To'] = SMTP_TO_EMAIL
        
        # Create HTML email body
        html_body = f"""
        <html>
        <head>
            <style>
                body {{ font-family: Arial, sans-serif; line-height: 1.6; color: #333; }}
                .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                .header {{ background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; border-radius: 8px 8px 0 0; }}
                .content {{ background: #f9f9f9; padding: 20px; border-radius: 0 0 8px 8px; }}
                .field {{ margin-bottom: 15px; }}
                .label {{ font-weight: bold; color: #667eea; }}
                .value {{ margin-top: 5px; }}
                .footer {{ margin-top: 20px; padding-top: 20px; border-top: 2px solid #ddd; font-size: 12px; color: #666; }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <h2 style="margin: 0;">🎯 New Contact Form Submission</h2>
                </div>
                <div class="content">
                    <div class="field">
                        <div class="label">👤 Name:</div>
                        <div class="value">{enquiry_data['name']}</div>
                    </div>
                    <div class="field">
                        <div class="label">📧 Email:</div>
                        <div class="value"><a href="mailto:{enquiry_data['email']}">{enquiry_data['email']}</a></div>
                    </div>
                    <div class="field">
                        <div class="label">📱 Phone:</div>
                        <div class="value"><a href="tel:{enquiry_data['phone']}">{enquiry_data['phone']}</a></div>
                    </div>
                    <div class="field">
                        <div class="label">🏢 Company:</div>
                        <div class="value">{enquiry_data.get('company', 'Not provided')}</div>
                    </div>
                    <div class="field">
                        <div class="label">💬 Message:</div>
                        <div class="value">{enquiry_data['message']}</div>
                    </div>
                    <div class="footer">
                        <p>📅 Submitted: {enquiry_data['created_at']}</p>
                        <p>🌐 Source: TechResona Website Contact Form</p>
                    </div>
                </div>
            </div>
        </body>
        </html>
        """
        
        # Create plain text version
        text_body = f"""
New Enquiry Received!

Name: {enquiry_data['name']}
Email: {enquiry_data['email']}
Phone: {enquiry_data['phone']}
Company: {enquiry_data.get('company', 'Not provided')}

Message:
{enquiry_data['message']}

Submitted: {enquiry_data['created_at']}
Source: Website Contact Form
        """
        
        # Attach both text and HTML versions
        part1 = MIMEText(text_body, 'plain')
        part2 = MIMEText(html_body, 'html')
        msg.attach(part1)
        msg.attach(part2)
        
        # Send email
        with smtplib.SMTP(SMTP_HOST, SMTP_PORT) as server:
            server.starttls()
            server.login(SMTP_USER, SMTP_PASSWORD)
            server.send_message(msg)
        
        print(f"Email notification sent successfully to {SMTP_TO_EMAIL}")
        return True
        
    except Exception as e:
        print(f"Error sending email notification: {e}")
        return False

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
        db_status = "not_configured"
        if db:
            try:
                await db.command('ping')
                db_status = "connected"
            except:
                db_status = "disconnected"
        
        return {
            "status": "healthy",
            "database": db_status,
            "slack_configured": bool(SLACK_WEBHOOK_URL),
            "email_configured": bool(SMTP_USER and SMTP_PASSWORD)
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {str(e)}")

@app.post("/api/enquiries", response_model=EnquiryResponse)
async def create_enquiry(enquiry: EnquiryRequest):
    """
    Create a new enquiry from the contact form.
    Saves to MongoDB (if available) and sends notifications.
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
        
        enquiry_id = None
        
        # Save to MongoDB if available
        if enquiries_collection:
            try:
                result = await enquiries_collection.insert_one(enquiry_data)
                enquiry_id = str(result.inserted_id)
                print(f"✅ Enquiry saved to database: {enquiry_id}")
            except Exception as e:
                print(f"⚠️  Failed to save to database: {e}")
        else:
            # Log to console if no database
            print(f"📝 New Enquiry (No DB):")
            print(f"   Name: {enquiry.name}")
            print(f"   Email: {enquiry.email}")
            print(f"   Phone: {enquiry.phone}")
            print(f"   Company: {enquiry.company}")
            print(f"   Message: {enquiry.message}")
        
        # Send email notification (non-blocking)
        email_sent = await send_email_notification(enquiry_data)
        if email_sent:
            print("✅ Email notification sent")
        
        # Send Slack notification (non-blocking)
        slack_sent = await send_slack_notification(enquiry_data)
        if slack_sent:
            print("✅ Slack notification sent")
        
        return EnquiryResponse(
            success=True,
            message="Thank you for your enquiry! We'll get back to you within 24 hours.",
            enquiry_id=enquiry_id
        )
    
    except Exception as e:
        print(f"❌ Error creating enquiry: {e}")
        raise HTTPException(
            status_code=500,
            detail="Failed to submit enquiry. Please try again or contact us directly."
        )

@app.get("/api/enquiries")
async def list_enquiries(skip: int = 0, limit: int = 50):
    """
    List all enquiries (admin endpoint - should be protected in production)
    """
    if not enquiries_collection:
        raise HTTPException(status_code=503, detail="Database not configured")
    
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
    if not enquiries_collection:
        raise HTTPException(status_code=503, detail="Database not configured")
    
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
    # Run on port 9001 for production deployment
    uvicorn.run(app, host="0.0.0.0", port=9001)
