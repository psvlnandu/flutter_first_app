# ==================== backend/main.py ====================

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import httpx
import os
from dotenv import load_dotenv

load_dotenv()

app = FastAPI()

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
            return response.json()
    except Exception as e:
        return {"error": str(e)}
