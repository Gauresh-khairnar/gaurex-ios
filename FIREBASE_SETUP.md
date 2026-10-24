# GAUREX Executive Dashboard — Firebase Setup & Deployment Guide
**Founder & Owner:** Gauresh Khairnar (`OWNER`)

---

## 1. Firebase Project Creation

1. Navigate to the [Firebase Console](https://console.firebase.google.com/).
2. Create a new Firebase project named **`GAUREX-Business`**.
3. Add an **Apple iOS App** to the project:
   - **Bundle Identifier:** `com.gaurex.dashboard`
   - **App Nickname:** `GAUREX Dashboard`
4. Download `GoogleService-Info.plist` and place it in the `Gaurex/` directory.

---

## 2. Authentication Configuration

1. In the Firebase Console, go to **Build > Authentication**.
2. Enable **Email/Password** authentication.
3. Create the Founder & Owner account:
   - **Email:** `gauresh@gaurex.com`
   - Set custom user claims via Firebase Admin SDK:
     ```json
     { "role": "OWNER" }
     ```

---

## 3. Cloud Firestore Deployment

Deploy the security rules and indexes included in the `backend/` directory:

```bash
# Install Firebase CLI if not present
npm install -g firebase-tools

# Login to your Google/Firebase account
firebase login

# Initialize project inside backend/
cd backend
firebase use --add YOUR_FIREBASE_PROJECT_ID

# Deploy Firestore Security Rules and Composite Indexes
firebase deploy --only firestore:rules,firestore:indexes
```

---

## 4. Firebase Storage Deployment

Deploy the strict storage rules for client contracts, invoices, and employee documents:

```bash
cd backend
firebase deploy --only storage
```

---

## 5. Secure AI Cloud Functions Gateway

Deploy the Cloud Function that handles authenticated queries for the GAUREX AI Business Assistant:

```bash
cd backend/functions
npm install
npm run build
firebase deploy --only functions:askBusinessAI
```

Set your preferred LLM API key as a secure secret in Google Cloud Secret Manager:
```bash
firebase functions:secrets:set GEMINI_API_KEY
# or
firebase functions:secrets:set OPENAI_API_KEY
```
