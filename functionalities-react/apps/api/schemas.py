from pydantic import BaseModel, Field
from typing import Dict, Any, Optional, List
from datetime import datetime
from uuid import UUID

class ConsentBase(BaseModel):
    user_did: str
    purpose_tag: str
    data_fields: Dict[str, Any] = {}
    requester_name: Optional[str] = None
    purpose: Optional[str] = None
    disclosure_mode: str = "verified_proof"
    scope: Dict[str, Any] = {}
    credit_offer: Optional[str] = None
    region: Optional[str] = None
    minimum_cohort_size: int = 0

class ConsentCreate(ConsentBase):
    ttl_seconds: int = Field(..., description="Time-To-Live for the consent in seconds")

class ConsentResponse(ConsentBase):
    id: UUID
    requester_name: Optional[str] = None
    purpose: Optional[str] = None
    disclosure_mode: str
    scope: Dict[str, Any] = {}
    credit_offer: Optional[str] = None
    region: Optional[str] = None
    minimum_cohort_size: int
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
    purpose: str
    category: Optional[str] = None
    scope: Dict[str, Any] = {}
    disclosure_modes: List[str] = []
    credit_offer: str
    region: Optional[str] = None
    minimum_cohort_size: int = 0
    duration_days: int = 30
    reward_amount: str
    created_at: datetime

    class Config:
        from_attributes = True

class MarketplaceConsentRequest(BaseModel):
    user_did: str
    request_id: UUID
    disclosure_mode: str = "regional_anonymized"
    requested_scope: Dict[str, Any] = {}

class MarketplaceConsentResponse(BaseModel):
    status: str
    payout_id: str
    summary: str
    reward_amount: str
    credit_offer: str
    disclosure_mode: str
    consent_id: UUID
    output_type: str
    protected_output: Dict[str, Any]

class WalletStatus(BaseModel):
    user_did: str
    token_balance: str

class ComplianceScanRequest(BaseModel):
    content: str

class ComplianceScanResponse(BaseModel):
    violations: list[str]
    health_score: int
    recommendations: list[str]

class ShieldAccessRequest(BaseModel):
    user_did: str
    consent_id: UUID
    requester_name: str
    purpose: str
    requested_fields: List[str] = []
    resource: Optional[str] = None
    tool_name: Optional[str] = None

class ShieldAccessResponse(BaseModel):
    decision: str
    reason: str
    event_id: UUID
    allowed_fields: List[str] = []
    protected_payload: Dict[str, Any] = {}

class AccessEventResponse(BaseModel):
    id: UUID
    user_did: str
    consent_id: Optional[UUID] = None
    requester_name: str
    tool_name: Optional[str] = None
    purpose: str
    requested_fields: List[str] = []
    resource: Optional[str] = None
    decision: str
    reason: str
    policy_snapshot: Dict[str, Any] = {}
    is_violation: bool
    created_at: datetime

    class Config:
        from_attributes = True

class RegionalInsightRequest(BaseModel):
    request_id: UUID
    region: str
    cohort_size: int

class RegionalInsightResponse(BaseModel):
    status: str
    region: str
    cohort_size: int
    minimum_cohort_size: int
    insight: Dict[str, Any] = {}
    reason: Optional[str] = None

class EnterpriseConsentProvider(BaseModel):
    consent_id: UUID
    user_did: str
    requester_name: Optional[str] = None
    purpose: Optional[str] = None
    disclosure_mode: str
    region: Optional[str] = None
    approved_fields: List[str] = []
    credit_offer: Optional[str] = None
    expires_at: datetime
    status: str
    created_at: datetime

class EnterpriseRegionalCohort(BaseModel):
    requester_name: str
    region: str
    disclosure_mode: str
    consent_count: int
    minimum_cohort_size: int
    status: str
    approved_fields: List[str] = []
    insight: Dict[str, Any] = {}

class EnterpriseConsentProvidersResponse(BaseModel):
    total_active_consents: int
    identifiable_provider_count: int
    anonymous_cohort_count: int
    providers: List[EnterpriseConsentProvider] = []
    regional_cohorts: List[EnterpriseRegionalCohort] = []
