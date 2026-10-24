import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

admin.initializeApp();
const db = admin.firestore();

/**
 * GAUREX Executive AI Assistant Cloud Function
 * Secure server-side gateway that verifies OWNER auth before querying LLMs.
 */
export const askBusinessAI = functions.https.onCall(async (data, context) => {
  // 1. Verify Authentication & Role
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Executive authentication required."
    );
  }

  const userEmail = context.auth.token.email;
  const userRole = context.auth.token.role;
  
  if (userRole !== "OWNER" && userEmail !== "gauresh@gaurex.com") {
    throw new functions.https.HttpsError(
      "permission-denied",
      "Only Founder & Owner Gauresh Khairnar can access business intelligence."
    );
  }

  const { question } = data;
  if (!question || typeof question !== "string") {
    throw new functions.https.HttpsError("invalid-argument", "Question required.");
  }

  // 2. Query Read-Only Financial Ledger & Aggregations
  const invoicesSnap = await db.collection("invoices").get();
  const paymentsSnap = await db.collection("payments").get();
  const clientsSnap = await db.collection("clients").get();
  const workersSnap = await db.collection("workers").get();

  let totalInvoiced = 0;
  let overdueCount = 0;
  const now = new Date();

  invoicesSnap.forEach((doc) => {
    const inv = doc.data();
    if (inv.status !== "cancelled") {
      totalInvoiced += inv.totalAmount || 0;
      if (inv.dueDate && inv.dueDate.toDate() < now && inv.status !== "paid") {
        overdueCount++;
      }
    }
  });

  let totalCollected = 0;
  paymentsSnap.forEach((doc) => {
    totalCollected += doc.data().amount || 0;
  });

  const outstanding = Math.max(0, totalInvoiced - totalCollected);

  // 3. Structured context for LLM
  const contextSummary = {
    founder: "Gauresh Khairnar",
    company: "GAUREX",
    totalClients: clientsSnap.size,
    totalWorkers: workersSnap.size,
    totalInvoiced,
    totalCollected,
    outstandingPayments: outstanding,
    overdueInvoicesCount: overdueCount,
    currency: "INR"
  };

  return {
    success: true,
    contextSummary,
    timestamp: new Date().toISOString()
  };
});
