# PRISM: Consent Economy Platform

PRISM is a privacy-first platform designed for **DPDP (Digital Personal Data Protection)** compliance, leveraging Zero-Knowledge Proofs (ZKP) and W3C Decentralized Identifiers (DIDs).

## Architecture Overview

PRISM is organized as a monorepo with three primary layers:

### 1. Identity Layer (L1) - W3C DIDs
- **Technology**: Polygon ID JS SDK.
- **Role**: Manages the issuance and verification of Decentralized Identifiers (DIDs). 
- **Interaction**: Users hold their identity locally. When a service requests data, L1 provides the necessary cryptographic basis for proving identity without revealing the underlying PII (Personally Identifiable Information).

### 2. Consent Layer (L2) - DPDP Compliance
- **Technology**: FastAPI (Backend) + PostgreSQL (Database).
- **Role**: Tracks and manages granular consent records. It ensures that every data access request is backed by a valid, user-approved consent artifact.
- **Interaction**: Acts as the orchestrator between data consumers (e.g., banks, medical apps) and data providers (users). It verifies proofs generated in L1 before granting access.

### 3. Proof Layer (L3) - ZKPs
- **Technology**: Circom + SnarkJS.
- **Role**: Generates Zero-Knowledge Proofs for selective disclosure (e.g., proving age without revealing birth date).
- **Interaction**: Circuits are shared between the frontend (for proof generation) and backend (for verification).

## Project Structure

```bash
PRISM/
├── apps/
│   ├── web/          # React (Vite) + Tailwind Frontend
│   └── api/          # FastAPI Backend
├── circuits/         # Circom circuits for ZKPs
├── packages/         # Shared logic and types
├── infra/            # Docker and orchestration config
└── scripts/          # Automation scripts
```

## Getting Started

### Prerequisites
- Node.js (v18+)
- Docker & Docker Compose
- Circom (for circuit changes)

### Running Locally

1. **Start Infrastructure**:
   ```bash
   docker-compose up -d
   ```

2. **Frontend Development**:
   ```bash
   cd apps/web
   npm install
   npm run dev
   ```

3. **Backend Development**:
   ```bash
   cd apps/api
   pip install -r requirements.txt
   uvicorn main:app --reload
   ```

4. **Compile Circuits**:
   ```bash
   npm run compile:circuits
   ```

## Identity (L1) & Consent (L2) Interaction Flow

1. **Issue DID**: A user receives an identity credential in their digital wallet (Identity Layer).
2. **Request Consent**: A data consumer requests specific information (e.g., "Is this user over 18?").
3. **Generate Proof**: PRISM frontend uses the Identity Layer artifacts and local ZKP circuits to generate a proof (Proof Layer).
4. **Verify & log**: The Consent Layer (L2) receives the proof, verifies it via the API, and logs the outcome in the DPDP-compliant ledger.
