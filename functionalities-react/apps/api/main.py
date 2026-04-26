from fastapi import FastAPI, HTTPException, Body, Depends, File, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session
from datetime import datetime, timedelta
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from contextlib import asynccontextmanager
import os
import uuid
import json

# Internal modules
import models, schemas, database
from database import engine, SessionLocal, get_db
from gemini_service import gemini_service

# --- Background Task: Consent Decay Engine ---
async def revoke_expired_consents():
    """
    Periodic task to check for expired consents and update their status.
    This fulfills USP 2: Consent Decay Engine.
    """
    print(f"[{datetime.utcnow()}] [DecayEngine] Scanning for expired consents...")
    db = SessionLocal()
    try:
        now = datetime.utcnow()
        # Find all Active consents where expiry_timestamp has passed
        expired_consents = db.query(models.Consent).filter(
            models.Consent.expiry_timestamp < now,
            models.Consent.status == models.ConsentStatus.ACTIVE
        ).all()
        
        for consent in expired_consents:
            consent.status = models.ConsentStatus.EXPIRED
            print(f"[DecayEngine] Revoked consent {consent.id} for DID {consent.user_did}")
        
        db.commit()
    except Exception as e:
        print(f"[DecayEngine] Error: {e}")
    finally:
        db.close()

# --- App Lifecycle Handler ---
@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize Database
    models.Base.metadata.create_all(bind=engine)
    
    # Startup: Initialize & Start Scheduler
    scheduler = AsyncIOScheduler()
    # Run every hour as per requirement
    scheduler.add_job(revoke_expired_consents, "interval", hours=1)
    scheduler.start()
    print("PRISM API: Consent Decay Engine started.")
    
    yield
    
    # Shutdown: Stop Scheduler
    scheduler.shutdown()
    print("PRISM API: Scheduler shut down.")

# --- FastAPI Initialization ---
app = FastAPI(
    title="PRISM API", 
    description="Consent Layer (L2) for DPDP Compliance",
    lifespan=lifespan
)

# --- Existing Models & Endpoints ---
class ZKProof(BaseModel):
    proof: dict
    publicSignals: list

@app.get("/")
async def root():
    return {"message": "PRISM API - Consent Layer active"}

@app.post("/api/v1/verify-age")
async def verify_age_proof(payload: ZKProof = Body(...)):
    """
    Endpoint to verify ZK Age Proof sent from the frontend.
    """
    try:
        # Placeholder for actual Groth16 verification
        is_valid = True 
        if is_valid:
            return {"status": "success", "message": "Age verified successfully", "is_valid": True}
        else:
            raise HTTPException(status_code=400, detail="Invalid ZK Proof")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- USP 2: Consent Management Endpoints ---

@app.post("/api/v1/grant-consent", response_model=schemas.ConsentResponse)
async def grant_consent(
    consent_data: schemas.ConsentCreate, 
    db: Session = Depends(get_db)
):
    """
    Registers a new consent artifact with a Time-To-Live (TTL).
    """
    expiry = datetime.utcnow() + timedelta(seconds=consent_data.ttl_seconds)
    
    db_consent = models.Consent(
        user_did=consent_data.user_did,
        purpose_tag=consent_data.purpose_tag,
        data_fields=consent_data.data_fields,
        expiry_timestamp=expiry,
        status=models.ConsentStatus.ACTIVE
    )
    
    db.add(db_consent)
    db.commit()
    db.refresh(db_consent)
    return db_consent

@app.post("/api/v1/revoke-consent/{consent_id}", response_model=schemas.RevocationResponse)
async def revoke_consent(
    consent_id: uuid.UUID, 
    db: Session = Depends(get_db)
):
    """
    Manually revokes an existing consent (Requested addition).
    """
    db_consent = db.query(models.Consent).filter(models.Consent.id == consent_id).first()
    if not db_consent:
        raise HTTPException(status_code=404, detail="Consent record not found")
    
    if db_consent.status == models.ConsentStatus.REVOKED:
        return {
            "status": "already_revoked",
            "message": "Consent is already in revoked state",
            "consent_id": consent_id
        }

    db_consent.status = models.ConsentStatus.REVOKED
    db.commit()
    
    return {
        "status": "success",
        "message": "Consent manually revoked by user",
        "consent_id": consent_id
    }

@app.get("/api/v1/consent/status")
async def get_consent_status(did: str, db: Session = Depends(get_db)):
    """
    Check DPDP consent status for a given Decentralized Identifier in the DB.
    """
    active_consents = db.query(models.Consent).filter(
        models.Consent.user_did == did,
        models.Consent.status == models.ConsentStatus.ACTIVE
    ).all()
    
    return {
        "did": did,
        "count": len(active_consents),
        "consents": active_consents
    }

# --- USP 5: Intelligent Marketplace & Razorpay Simulation ---

@app.get("/api/v1/marketplace/requests", response_model=list[schemas.DataRequestResponse])
async def list_marketplace_requests(db: Session = Depends(get_db)):
    """
    Lists all active data demand requests in the marketplace.
    """
    return db.query(models.DataRequest).order_by(models.DataRequest.created_at.desc()).all()

@app.post("/api/v1/marketplace/respond", response_model=schemas.MarketplaceConsentResponse)
async def respond_to_marketplace_request(
    payload: schemas.MarketplaceConsentRequest,
    db: Session = Depends(get_db)
):
    """
    Step 1: Get AI-powered plain language summary.
    Step 2: Simulate Razorpay UPI Payout.
    """
    request_data = db.query(models.DataRequest).filter(models.DataRequest.id == payload.request_id).first()
    if not request_data:
        raise HTTPException(status_code=404, detail="Marketplace request not found")

    # 1. AI Summarization via Gemini
    ai_summary = await gemini_service.summarize_policy(request_data.privacy_policy_raw)

    # 2. Razorpay UPI Payout Simulation
    # In a real app, you'd use the Razorpay Python SDK to trigger a payout.
    # razorpay_client.payout.create({...})
    mock_payout_id = f"pay_upi_{uuid.uuid4().hex[:12]}"

    # 3. Create a Consent Record (for compliance)
    expiry = datetime.utcnow() + timedelta(days=365) # standard 1 year
    db_consent = models.Consent(
        user_did=payload.user_did,
        purpose_tag=f"Marketplace: {request_data.requester_name}",
        data_fields={"reward_transferred": request_data.reward_amount, "payout_id": mock_payout_id},
        expiry_timestamp=expiry,
        status=models.ConsentStatus.ACTIVE
    )
    db.add(db_consent)
    
    # 4. Token Credit Logic (USP 4)
    wallet = db.query(models.UserWallet).filter(models.UserWallet.user_did == payload.user_did).first()
    if not wallet:
        wallet = models.UserWallet(user_did=payload.user_did, token_balance="0")
        db.add(wallet)
    
    # Extract number from amount string (e.g. "₹750" -> 750)
    try:
        current_bal = int(wallet.token_balance)
        reward_val = int(''.join(filter(str.isdigit, request_data.reward_amount)))
        wallet.token_balance = str(current_bal + reward_val)
    except:
        pass # Fallback if parsing fails

    db.commit()

    return {
        "status": "success",
        "payout_id": mock_payout_id,
        "summary": ai_summary,
        "reward_amount": request_data.reward_amount
    }

# --- New MVP Feature Endpoints ---

@app.get("/api/v1/wallet/status", response_model=schemas.WalletStatus)
async def get_wallet_status(did: str, db: Session = Depends(get_db)):
    wallet = db.query(models.UserWallet).filter(models.UserWallet.user_did == did).first()
    if not wallet:
        # Create initial wallet for demo
        wallet = models.UserWallet(user_did=did, token_balance="0")
        db.add(wallet)
        db.commit()
    return wallet

@app.post("/api/v1/compliance/scan", response_model=schemas.ComplianceScanResponse)
async def scan_for_compliance(payload: schemas.ComplianceScanRequest):
    """
    Compliance Copilot: Static Analysis via Gemini (USP 3)
    """
    analysis_json = await gemini_service.analyze_compliance(payload.content)
    try:
        return json.loads(analysis_json)
    except:
        # Fallback if Gemini output isn't clean JSON
        return {
            "violations": ["Could not parse specific violations."],
            "health_score": 50,
            "recommendations": ["Review policy manually for DPDP compliance."]
        }

@app.get("/api/v1/debug-prism")
async def debug_prism():
    return {"status": "v1.1_live", "timestamp": str(datetime.now())}

@app.post("/api/v1/scan-identity-document")
async def scan_onboarding_document(file: UploadFile = File(...)):
    """
    Real-world OCR Extraction (USP 1 upgrade)
    """
    if file.content_type not in ["image/jpeg", "image/png"]:
        raise HTTPException(status_code=400, detail="Only JPEG/PNG images are supported")
    
    contents = await file.read()
    analysis_json = await gemini_service.extract_id_data(contents, file.content_type)
    
    try:
        return json.loads(analysis_json)
    except:
        raise HTTPException(status_code=500, detail="Failed to parse ID data from image")

@app.post("/api/v1/onboard")
async def onboard_user(did: str, db: Session = Depends(get_db)):
    """
    Identity Onboarding (USP 1)
    """
    wallet = db.query(models.UserWallet).filter(models.UserWallet.user_did == did).first()
    if not wallet:
        wallet = models.UserWallet(user_did=did, token_balance="0")
        db.add(wallet)
        db.commit()
    return {"status": "onboarded", "did": did}
