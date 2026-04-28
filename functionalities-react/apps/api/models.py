from sqlalchemy import Boolean, Column, Integer, String, DateTime, Enum, JSON
from sqlalchemy.dialects.postgresql import UUID, JSONB
from database import Base
import uuid
import datetime

class ConsentStatus(str, Enum):
    ACTIVE = "Active"
    REVOKED = "Revoked"
    EXPIRED = "Expired"

class Consent(Base):
    __tablename__ = "consents"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_did = Column(String, index=True, nullable=False)
    requester_name = Column(String, nullable=True)
    purpose_tag = Column(String, index=True, nullable=False)
    purpose = Column(String, nullable=True)
    disclosure_mode = Column(String, nullable=False, default="verified_proof")
    data_fields = Column(JSONB, nullable=False, default={})
    scope = Column(JSONB, nullable=False, default={})
    credit_offer = Column(String, nullable=True)
    region = Column(String, nullable=True)
    minimum_cohort_size = Column(Integer, nullable=False, default=0)
    access_policy = Column(JSONB, nullable=False, default={})
    expiry_timestamp = Column(DateTime, nullable=False)
    status = Column(String, default=ConsentStatus.ACTIVE)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

class DataRequest(Base):
    __tablename__ = "data_requests"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    requester_name = Column(String, nullable=False)
    title = Column(String, nullable=False)
    description = Column(String, nullable=False)
    purpose = Column(String, nullable=False, default="Not specified")
    category = Column(String, nullable=True)
    scope = Column(JSONB, nullable=False, default={})
    disclosure_modes = Column(JSONB, nullable=False, default=[])
    credit_offer = Column(String, nullable=False, default="0 credits")
    region = Column(String, nullable=True)
    minimum_cohort_size = Column(Integer, nullable=False, default=0)
    duration_days = Column(Integer, nullable=False, default=30)
    reward_amount = Column(String, nullable=False) # e.g. "₹500"
    privacy_policy_raw = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class UserWallet(Base):
    __tablename__ = "user_wallets"

    user_did = Column(String, primary_key=True, index=True)
    token_balance = Column(String, default="0")
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)

class AccessEvent(Base):
    __tablename__ = "access_events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_did = Column(String, index=True, nullable=False)
    consent_id = Column(UUID(as_uuid=True), nullable=True, index=True)
    requester_name = Column(String, nullable=False)
    tool_name = Column(String, nullable=True)
    purpose = Column(String, nullable=False)
    requested_fields = Column(JSONB, nullable=False, default=[])
    resource = Column(String, nullable=True)
    decision = Column(String, nullable=False)
    reason = Column(String, nullable=False)
    policy_snapshot = Column(JSONB, nullable=False, default={})
    is_violation = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
