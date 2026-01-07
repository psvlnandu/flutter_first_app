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
            print(f"Validation Response: {data}")
            return data
    except Exception as e:
        return {"error": str(e)}
    
@app.post("/api/generate-verification-link")
async def generate_link(email: str):
    try:
        # 2. Define where the user goes AFTER clicking the link
        action_code_settings = auth.ActionCodeSettings(
            url='https://coffeshop-app-c229c.firebaseapp.com/checkout', # The redirect URL
            handle_code_in_app=True,
            ios_bundle_id='com.you.coffeeshop',
            android_package_name='com.example.coffeeshop',
            android_install_app=True,
            android_minimum_version='12',
        )

        # 3. Generate the actual link
        link = auth.generate_email_verification_link(email, action_code_settings)
        
        # 4. In a real app, you'd email this 'link' to the user here.
        # For now, we'll just return it to the Flutter app to test.
        return {"verification_link": link}
    except Exception as e:
        return {"error": str(e)}
    
@app.post("/api/guest-verify")
async def guest_verify(request: dict):
    email = request.get("email")
    uid = request.get("uid")
    
    try:
        # 1. Update the anonymous user with the email (No password needed!)
        auth.update_user(uid, email=email)
        
        # 2. Setup where the user returns after clicking
        action_code_settings = auth.ActionCodeSettings(
            url='https://coffeshop-app-c229c.firebaseapp.com/checkout',
            handle_code_in_app=True,
            ios_bundle_id='com.example.coffeeshop',
            android_package_name='com.example.coffeeshop',
        )

        # 3. Generate the link
        link = auth.generate_email_verification_link(email, action_code_settings)
        
        return {"status": "success", "link": link}
    except Exception as e:
        return {"error": str(e)}