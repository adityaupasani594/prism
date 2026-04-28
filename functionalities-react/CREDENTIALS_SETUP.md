# PRISM Credentials Setup

This project must not commit real API keys, `.env` files, Firebase local config, service account JSON, private keys, or generated credential files. Use the `.env.example` files as templates and keep real values local.

## Required for the MVP

### Gemini API key

PRISM uses Gemini in the FastAPI backend for plain-language consent summaries, DPDP compliance scanning, and identity-document attribute extraction.

1. Open Google AI Studio: https://aistudio.google.com/
2. Sign in with your Google account.
3. Create an API key.
4. Copy `functionalities-react/apps/api/.env.example` to `functionalities-react/apps/api/.env`.
5. Set:

```env
GOOGLE_API_KEY=your_gemini_api_key
```

Do not paste the key into source code.

### PostgreSQL credentials

The backend reads database settings from environment variables in `functionalities-react/apps/api/database.py`.

For local Docker Compose, the defaults are:

```env
DB_USER=postgres
DB_PASSWORD=prism_secret
DB_HOST=localhost
DB_PORT=5432
DB_NAME=prism_db
```

You can place these in `functionalities-react/apps/api/.env` when running the API directly, or use a root/local `.env` for Docker Compose. If you use a single connection string, set:

```env
DATABASE_URL=postgresql://user:password@host:port/db
```

## Optional for this iteration

### Firebase web app config

Firebase is optional for the current MVP. If Firebase Auth or Firestore is added later:

1. Open the Firebase console: https://console.firebase.google.com/
2. Create or select a project.
3. Add a Web app.
4. Copy `functionalities-react/apps/web/.env.example` to `functionalities-react/apps/web/.env.local`.
5. Fill in the `VITE_FIREBASE_*` values from the Firebase web app config.

Firebase web config is client-side configuration, but keep local env files untracked so environments can differ safely.

## Future production credentials

### Google Cloud service account JSON

Only use a service account JSON for server-side Google Cloud APIs such as Secret Manager, Cloud KMS, BigQuery, or Vertex AI.

1. In Google Cloud Console, create or select a project.
2. Enable only the APIs you need.
3. Create a service account with least-privilege IAM roles.
4. Download the JSON key only if local development requires it.
5. Store it at:

```text
functionalities-react/apps/api/secrets/google-service-account.json
```

6. In `functionalities-react/apps/api/.env`, set:

```env
GOOGLE_APPLICATION_CREDENTIALS=./secrets/google-service-account.json
```

Never commit the JSON file.

### Razorpay or partner credit APIs

The hackathon MVP simulates credits and does not require payment credentials. If real partner credits or payouts are added later, keep keys in `functionalities-react/apps/api/.env`:

```env
RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_KEY_SECRET=your_razorpay_key_secret
```

## Pre-push checklist

- Run `git status --short` and confirm no `.env`, `.env.local`, service account JSON, private keys, or `secrets/` files are staged.
- Commit `.env.example` templates only.
- Rotate any secret immediately if it was ever committed by mistake.
