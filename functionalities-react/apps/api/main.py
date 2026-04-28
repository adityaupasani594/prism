from fastapi import FastAPI, HTTPException, Body, Depends, File, UploadFile
from pydantic import BaseModel
from sqlalchemy.orm import Session
from sqlalchemy import inspect, text
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

DISCLOSURE_MODES = {
    "regional_anonymized": "Regional anonymized insight",
    "verified_proof": "Verified proof",
    "limited_raw": "Limited raw sharing",
}

DISCLOSURE_OUTPUT_TYPES = {
    "regional_anonymized": "aggregate_insight",
    "verified_proof": "zero_knowledge_or_credential_proof",
    "limited_raw": "scoped_personal_fields",
}

def _extract_allowed_fields(consent: models.Consent) -> list[str]:
    scope = consent.scope or {}
    if isinstance(scope.get("fields"), list):
        return [str(field) for field in scope["fields"]]

    data_fields = consent.data_fields or {}
    if isinstance(data_fields, dict):
        return [str(field) for field, enabled in data_fields.items() if enabled is not False]

    return []

def _build_policy_snapshot(consent: models.Consent) -> dict:
    return {
        "consent_id": str(consent.id),
        "requester_name": consent.requester_name,
        "purpose": consent.purpose or consent.purpose_tag,
        "disclosure_mode": consent.disclosure_mode,
        "allowed_fields": _extract_allowed_fields(consent),
        "expiry_timestamp": consent.expiry_timestamp.isoformat(),
        "status": consent.status,
        "region": consent.region,
    }

def _protected_output_for_mode(request_data: models.DataRequest, disclosure_mode: str, consent_id: uuid.UUID) -> dict:
    if disclosure_mode == "regional_anonymized":
        return {
            "region": request_data.region or "India",
            "cohort": "eligible users only",
            "insight": "Aggregated regional signal prepared; no individual record exported.",
            "privacy_controls": ["minimum_cohort_threshold", "no_direct_identifiers", "purpose_bound_access"],
        }
    if disclosure_mode == "verified_proof":
        return {
            "proof_type": "verified_attribute",
            "result": "User matches requested eligibility criteria.",
            "hidden_fields": ["date_of_birth", "document_number", "raw_identity_document"],
        }
    return {
        "consent_id": str(consent_id),
        "fields": (request_data.scope or {}).get("fields", []),
        "warning": "Only explicitly approved fields are available through PRISM Shield.",
    }

def ensure_schema_upgrades():
    """
    Adds demo columns when an older local database already exists.
    This avoids requiring Alembic migrations for the hackathon prototype.
    """
    inspector = inspect(engine)
    if "consents" in inspector.get_table_names():
        existing = {column["name"] for column in inspector.get_columns("consents")}
        consent_columns = {
            "requester_name": "VARCHAR",
            "purpose": "VARCHAR",
            "disclosure_mode": "VARCHAR NOT NULL DEFAULT 'verified_proof'",
            "scope": "JSONB NOT NULL DEFAULT '{}'::jsonb",
            "credit_offer": "VARCHAR",
            "region": "VARCHAR",
            "minimum_cohort_size": "INTEGER NOT NULL DEFAULT 0",
            "access_policy": "JSONB NOT NULL DEFAULT '{}'::jsonb",
        }
        with engine.begin() as connection:
            for column_name, ddl in consent_columns.items():
                if column_name not in existing:
                    connection.execute(text(f"ALTER TABLE consents ADD COLUMN {column_name} {ddl}"))

    if "data_requests" in inspector.get_table_names():
        existing = {column["name"] for column in inspector.get_columns("data_requests")}
        request_columns = {
            "purpose": "VARCHAR NOT NULL DEFAULT 'Not specified'",
            "category": "VARCHAR",
            "scope": "JSONB NOT NULL DEFAULT '{}'::jsonb",
            "disclosure_modes": "JSONB NOT NULL DEFAULT '[]'::jsonb",
            "credit_offer": "VARCHAR NOT NULL DEFAULT '0 credits'",
            "region": "VARCHAR",
            "minimum_cohort_size": "INTEGER NOT NULL DEFAULT 0",
            "duration_days": "INTEGER NOT NULL DEFAULT 30",
        }
        with engine.begin() as connection:
            for column_name, ddl in request_columns.items():
                if column_name not in existing:
                    connection.execute(text(f"ALTER TABLE data_requests ADD COLUMN {column_name} {ddl}"))

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
    ensure_schema_upgrades()
    
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
        requester_name=consent_data.requester_name,
        purpose_tag=consent_data.purpose_tag,
        purpose=consent_data.purpose or consent_data.purpose_tag,
        disclosure_mode=consent_data.disclosure_mode,
        data_fields=consent_data.data_fields,
        scope=consent_data.scope or {"fields": list(consent_data.data_fields.keys())},
        credit_offer=consent_data.credit_offer,
        region=consent_data.region,
        minimum_cohort_size=consent_data.minimum_cohort_size,
        access_policy={
            "ttl_seconds": consent_data.ttl_seconds,
            "allowed_fields": list((consent_data.scope or {}).get("fields", consent_data.data_fields.keys())),
            "disclosure_mode": consent_data.disclosure_mode,
        },
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

@app.get("/api/v1/consent-exchange/requests", response_model=list[schemas.DataRequestResponse])
async def list_consent_exchange_requests(db: Session = Depends(get_db)):
    """
    Revised PRISM naming for privacy-first enterprise data requests.
    Kept separate from the marketplace route so old clients continue to work.
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

    disclosure_mode = payload.disclosure_mode
    if disclosure_mode not in DISCLOSURE_MODES:
        raise HTTPException(status_code=400, detail="Unsupported disclosure mode")

    allowed_modes = request_data.disclosure_modes or [
        "regional_anonymized",
        "verified_proof",
        "limited_raw",
    ]
    if disclosure_mode not in allowed_modes:
        raise HTTPException(status_code=400, detail="Disclosure mode not allowed for this request")

    # 1. AI Summarization via Gemini
    ai_summary = await gemini_service.summarize_policy(request_data.privacy_policy_raw)

    # 2. Partner credit simulation. Real payouts are intentionally out of MVP scope.
    mock_credit_id = f"credit_{uuid.uuid4().hex[:12]}"

    # 3. Create a Consent Record (for compliance)
    expiry = datetime.utcnow() + timedelta(days=request_data.duration_days)
    scope = payload.requested_scope or request_data.scope or {}
    data_fields = {
        "disclosure_mode": disclosure_mode,
        "approved_fields": scope.get("fields", []),
        "output_type": DISCLOSURE_OUTPUT_TYPES[disclosure_mode],
    }
    db_consent = models.Consent(
        user_did=payload.user_did,
        requester_name=request_data.requester_name,
        purpose_tag=f"Consent Exchange: {request_data.requester_name}",
        purpose=request_data.purpose,
        disclosure_mode=disclosure_mode,
        data_fields=data_fields,
        scope=scope,
        credit_offer=request_data.credit_offer or request_data.reward_amount,
        region=request_data.region,
        minimum_cohort_size=request_data.minimum_cohort_size,
        access_policy={
            "allowed_fields": scope.get("fields", []),
            "duration_days": request_data.duration_days,
            "disclosure_mode": disclosure_mode,
            "request_id": str(request_data.id),
        },
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
        reward_val = int(''.join(filter(str.isdigit, request_data.credit_offer or request_data.reward_amount)))
        wallet.token_balance = str(current_bal + reward_val)
    except:
        pass # Fallback if parsing fails

    db.commit()
    db.refresh(db_consent)

    return {
        "status": "success",
        "payout_id": mock_credit_id,
        "summary": ai_summary,
        "reward_amount": request_data.reward_amount,
        "credit_offer": request_data.credit_offer or request_data.reward_amount,
        "disclosure_mode": disclosure_mode,
        "consent_id": db_consent.id,
        "output_type": DISCLOSURE_OUTPUT_TYPES[disclosure_mode],
        "protected_output": _protected_output_for_mode(request_data, disclosure_mode, db_consent.id),
    }

@app.post("/api/v1/consent-exchange/respond", response_model=schemas.MarketplaceConsentResponse)
async def respond_to_consent_exchange_request(
    payload: schemas.MarketplaceConsentRequest,
    db: Session = Depends(get_db)
):
    return await respond_to_marketplace_request(payload, db)

# --- PRISM Shield: Enterprise Access Governance ---

@app.post("/api/v1/shield/access-check", response_model=schemas.ShieldAccessResponse)
async def check_shield_access(
    payload: schemas.ShieldAccessRequest,
    db: Session = Depends(get_db)
):
    consent = db.query(models.Consent).filter(
        models.Consent.id == payload.consent_id,
        models.Consent.user_did == payload.user_did,
    ).first()

    decision = "blocked"
    reason = "Consent record not found"
    allowed_fields: list[str] = []
    protected_payload: dict = {}
    policy_snapshot: dict = {}

    if consent:
        allowed_fields = _extract_allowed_fields(consent)
        policy_snapshot = _build_policy_snapshot(consent)
        requested_fields = set(payload.requested_fields)
        approved_fields = set(allowed_fields)
        approved_purpose = (consent.purpose or consent.purpose_tag or "").strip().lower()
        requested_purpose = payload.purpose.strip().lower()

        if consent.status != models.ConsentStatus.ACTIVE:
            reason = f"Consent is {consent.status}"
        elif consent.expiry_timestamp < datetime.utcnow():
            consent.status = models.ConsentStatus.EXPIRED
            reason = "Consent expired before this access attempt"
        elif requested_purpose != approved_purpose:
            reason = "Requested purpose does not match approved purpose"
        elif requested_fields and not requested_fields.issubset(approved_fields):
            extra = sorted(requested_fields - approved_fields)
            reason = f"Requested fields exceed consent scope: {', '.join(extra)}"
        else:
            decision = "allowed"
            reason = "Access approved by PRISM Shield policy"
            protected_payload = {
                "disclosure_mode": consent.disclosure_mode,
                "fields": sorted(requested_fields or approved_fields),
                "resource": payload.resource,
                "expires_at": consent.expiry_timestamp.isoformat(),
            }

    event = models.AccessEvent(
        user_did=payload.user_did,
        consent_id=payload.consent_id,
        requester_name=payload.requester_name,
        tool_name=payload.tool_name,
        purpose=payload.purpose,
        requested_fields=payload.requested_fields,
        resource=payload.resource,
        decision=decision,
        reason=reason,
        policy_snapshot=policy_snapshot,
        is_violation=decision == "blocked",
    )
    db.add(event)
    db.commit()
    db.refresh(event)

    return {
        "decision": decision,
        "reason": reason,
        "event_id": event.id,
        "allowed_fields": allowed_fields,
        "protected_payload": protected_payload,
    }

@app.get("/api/v1/shield/audit-log", response_model=list[schemas.AccessEventResponse])
async def get_shield_audit_log(
    did: str | None = None,
    limit: int = 20,
    db: Session = Depends(get_db),
):
    query = db.query(models.AccessEvent)
    if did:
        query = query.filter(models.AccessEvent.user_did == did)
    return query.order_by(models.AccessEvent.created_at.desc()).limit(limit).all()

@app.post("/api/v1/privacy/regional-insight", response_model=schemas.RegionalInsightResponse)
async def get_regional_insight(
    payload: schemas.RegionalInsightRequest,
    db: Session = Depends(get_db),
):
    request_data = db.query(models.DataRequest).filter(models.DataRequest.id == payload.request_id).first()
    if not request_data:
        raise HTTPException(status_code=404, detail="Consent Exchange request not found")

    minimum = request_data.minimum_cohort_size or 100
    if payload.cohort_size < minimum:
        return {
            "status": "blocked",
            "region": payload.region,
            "cohort_size": payload.cohort_size,
            "minimum_cohort_size": minimum,
            "insight": {},
            "reason": "Cohort is too small for regional anonymized output",
        }

    return {
        "status": "available",
        "region": payload.region,
        "cohort_size": payload.cohort_size,
        "minimum_cohort_size": minimum,
        "insight": {
            "consent_likelihood": 0.72,
            "preferred_disclosure_mode": "regional_anonymized",
            "top_reason_to_consent": "service credits",
            "privacy_note": "No individual-level data is included in this response.",
        },
        "reason": None,
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
