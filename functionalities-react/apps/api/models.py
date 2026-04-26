from sqlalchemy import Column, String, DateTime, Enum, JSON
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
    purpose_tag = Column(String, index=True, nullable=False)
    data_fields = Column(JSONB, nullable=False, default={})
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
    reward_amount = Column(String, nullable=False) # e.g. "₹500"
    privacy_policy_raw = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

class UserWallet(Base):
    __tablename__ = "user_wallets"

    user_did = Column(String, primary_key=True, index=True)
    token_balance = Column(String, default="0")
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)
