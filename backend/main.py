# ==================== backend/main.py ====================
"""
install dependencies if didn't
pip install -r requirements.txt

RUN backend:
python -m uvicorn main:app --reload --port 3000
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx
import os
from dotenv import load_dotenv
from fastapi_mail import ConnectionConfig, FastMail, MessageSchema, MessageType

import firebase_admin
from firebase_admin import credentials, auth

load_dotenv()

app = FastAPI()

# 1. Initialize Firebase Admin (Use the JSON file you added to .gitignore!)
cred = credentials.Certificate(r"C:\Users\Nandhu\Documents\Flutter Apps\flutter_application_1\coffeshop-app-c229c-firebase-adminsdk-fbsvc-746581e718.json")
firebase_admin.initialize_app(cred)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

# ==================== REQUEST MODELS ====================

class AddressValidationRequest(BaseModel):
    address1: str
    address2: str = None
    city: str
    state: str
    zip: str

# ==================== ENDPOINTS ====================

@app.get("/health")
async def health_check():
    return {"status": "Backend is running!"}

@app.get("/api/autocomplete")
async def autocomplete(input: str, sessionToken: str):
    """Google Places Autocomplete proxy"""
    try:
        url = "https://maps.googleapis.com/maps/api/place/autocomplete/json"
        params = {
            "input": input,
            "key": GOOGLE_API_KEY,
            "sessiontoken": sessionToken,
            "components": "country:us",
            "language": "en",
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params)
            return response.json()
    except Exception as e:
        return {"error": str(e)}

@app.get("/api/place-details")
async def place_details(placeId: str, sessionToken: str):
    """Google Places Details proxy"""
    try:
        url = "https://maps.googleapis.com/maps/api/place/details/json"
        params = {
            "place_id": placeId,
            "key": GOOGLE_API_KEY,
            "sessiontoken": sessionToken,
            "fields": "address_components",
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params)
            return response.json()
    except Exception as e:
        return {"error": str(e)}

@app.post("/api/validate-address")
async def validate_address(request: AddressValidationRequest):
    """Google Address Validation proxy"""
    try:
        url = "https://addressvalidation.googleapis.com/v1:validateAddress"
        
        address_lines = [request.address1]
        if request.address2:
            address_lines.append(request.address2)
        
        payload = {
            "address": {
                "addressLines": address_lines,
                "locality": request.city,
                "administrativeArea": request.state,
                "postalCode": request.zip,
                "regionCode": "US",
            }
        }
        
        params = {"key": GOOGLE_API_KEY}
        
        async with httpx.AsyncClient() as client:
            response = await client.post(url, json=payload, params=params)
            data = response.json()
            # print(f"Validation Response: {data}")
            return data
    except Exception as e:
        return {"error": str(e)}
 
 
@app.post("/api/guest-verify")
async def guest_verify(request: dict):
    email = request.get("email")
    uid = request.get("uid")
    
    try:
        try:
            existing_user = auth.get_user_by_email(email)
            target_uid = existing_user.uid # Use the existing account's UID
        except auth.UserNotFoundError:
            # If not found, update the current anonymous user
            auth.update_user(uid, email=email)
            target_uid = uid

        # Generate the link
        action_code_settings = auth.ActionCodeSettings(
            url='https://coffeshop-app-c229c.firebaseapp.com/checkout',
            handle_code_in_app=True,
            ios_bundle_id='com.example.coffeeshop',
            android_package_name='com.example.coffeeshop',
        )
        link = auth.generate_email_verification_link(email, action_code_settings)
        
        await send_verification_email(email, link)
        return {"status": "success", "link": link}
    except Exception as e:
        return {"error": str(e)}
    
conf = ConnectionConfig(
    MAIL_USERNAME = os.getenv("MAIL_USERNAME"),
    MAIL_PASSWORD = os.getenv("MAIL_PASSWORD"),
    MAIL_FROM = os.getenv("MAIL_USERNAME"),
    MAIL_PORT = 587,
    MAIL_SERVER = "smtp.gmail.com",
    MAIL_STARTTLS = True,
    MAIL_SSL_TLS = False,
    USE_CREDENTIALS = True
)

async def send_verification_email(email: str, link: str):
    message = MessageSchema(
        subject="Verify your Coffee Order",
        recipients=[email],
        body=f"Click the link to verify your guest checkout: {link}",
        subtype=MessageType.html
    )
    fm = FastMail(conf)
    await fm.send_message(message)