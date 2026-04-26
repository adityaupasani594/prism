from pydantic import BaseModel, Field
from typing import Dict, Any, Optional
from datetime import datetime
from uuid import UUID

class ConsentBase(BaseModel):
    user_did: str
    purpose_tag: str
    data_fields: Dict[str, Any] = {}

class ConsentCreate(ConsentBase):
    ttl_seconds: int = Field(..., description="Time-To-Live for the consent in seconds")

class ConsentResponse(ConsentBase):
    id: UUID
    expiry_timestamp: datetime
    status: str
    created_at: datetime

    class Config:
        from_attributes = True

class RevocationResponse(BaseModel):
    status: str
    message: str
    consent_id: UUID

class DataRequestResponse(BaseModel):
    id: UUID
    requester_name: str
    title: str
    description: str
    reward_amount: str
    created_at: datetime

    class Config:
        from_attributes = True

class MarketplaceConsentRequest(BaseModel):
    user_did: str
    request_id: UUID

class MarketplaceConsentResponse(BaseModel):
    status: str
    payout_id: str
    summary: str
    reward_amount: str

class WalletStatus(BaseModel):
    user_did: str
    token_balance: str

class ComplianceScanRequest(BaseModel):
    content: str

class ComplianceScanResponse(BaseModel):
    violations: list[str]
    health_score: int
    recommendations: list[str]
