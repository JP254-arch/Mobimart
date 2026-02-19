/**
 * FINAL M-Pesa STK Push Server (Daraja)
 * - Secure (env-based secrets)
 * - STK Push initiation
 * - Proper callback handling
 * - Firestore transaction updates (for real-time frontend listening)
 */

require('dotenv').config();
const express = require('express');
const axios = require('axios');
const cors = require('cors');
const admin = require('firebase-admin');

const app = express();
app.use(cors());
app.use(express.json());

/* ================= FIREBASE ADMIN ================= */

// Use service account or GOOGLE_APPLICATION_CREDENTIALS env
// admin.initializeApp({
//   credential: admin.credential.applicationDefault(),
// });

const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

/* ================= ENV CONFIG ================= */

const {
  MPESA_CONSUMER_KEY,
  MPESA_CONSUMER_SECRET,
  MPESA_SHORTCODE,
  MPESA_PASSKEY,
  MPESA_CALLBACK_URL,
  PORT = 3000,
} = process.env;

if (!MPESA_CONSUMER_KEY || !MPESA_CONSUMER_SECRET || !MPESA_SHORTCODE || !MPESA_PASSKEY || !MPESA_CALLBACK_URL) {
  throw new Error(' Missing required M-Pesa environment variables');
}

/* ================= HELPERS ================= */

const getTimestamp = () => new Date().toISOString().replace(/[-:TZ.]/g, '').slice(0, 14);

async function getAccessToken() {
  const auth = Buffer.from(`${MPESA_CONSUMER_KEY}:${MPESA_CONSUMER_SECRET}`).toString('base64');
  const response = await axios.get('https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials', {
    headers: { Authorization: `Basic ${auth}` },
  });
  return response.data.access_token;
}

/* ================= STK PUSH ================= */

app.post('/stkpush', async (req, res) => {
  const { phone, amount, transactionId, userId } = req.body;

  if (!phone || !amount || !transactionId || !userId) {
    return res.status(400).json({ error: 'Missing required parameters' });
  }

  try {
    const token = await getAccessToken();
    const timestamp = getTimestamp();
    const password = Buffer.from(MPESA_SHORTCODE + MPESA_PASSKEY + timestamp).toString('base64');

    const payload = {
      BusinessShortCode: MPESA_SHORTCODE,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: Math.round(amount),
      PartyA: phone,
      PartyB: MPESA_SHORTCODE,
      PhoneNumber: phone,
      CallBackURL: MPESA_CALLBACK_URL,
      AccountReference: transactionId,
      TransactionDesc: 'Mobimart Cart Checkout',
    };

    const stkRes = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
      payload,
      { headers: { Authorization: `Bearer ${token}` } }
    );

    // Save the transaction in Firestore so frontend can listen for updates
    await db.collection('transactions').doc(transactionId).set({
      checkoutRequestId: stkRes.data.CheckoutRequestID,
      userId,
      amount,
      phone,
      status: 'pending',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    return res.json(stkRes.data);
  } catch (err) {
    console.error('STK PUSH ERROR:', err.response?.data || err.message);
    return res.status(500).json({ error: 'STK Push failed' });
  }
});

/* ================= MPESA CALLBACK ================= */

app.post('/mpesa-callback', async (req, res) => {
  try {
    const callback = req.body?.Body?.stkCallback;
    if (!callback) return res.json({ ResultCode: 0 });

    const { ResultCode, ResultDesc, CheckoutRequestID, CallbackMetadata } = callback;

    const snapshot = await db.collection('transactions')
      .where('checkoutRequestId', '==', CheckoutRequestID)
      .limit(1)
      .get();

    if (snapshot.empty) return res.json({ ResultCode: 0 });

    const txRef = snapshot.docs[0].ref;

    if (ResultCode === 0) {
      const items = CallbackMetadata?.Item || [];
      const receipt = items.find(i => i.Name === 'MpesaReceiptNumber')?.Value || null;

      await txRef.update({
        status: 'success',
        receipt,
        paidAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    } else {
      await txRef.update({
        status: 'failed',
        resultDesc: ResultDesc,
        failedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    return res.json({ ResultCode: 0, ResultDesc: 'Accepted' });
  } catch (err) {
    console.error('CALLBACK ERROR:', err);
    return res.json({ ResultCode: 0 });
  }
});

/* ================= HEALTH CHECK ================= */

app.get('/', (_, res) => {
  res.send('✅ Mobimart M-Pesa server running');
});

/* ================= START SERVER ================= */

app.listen(PORT, () => {
  console.log(`🚀 Mobimart M-Pesa server running on port ${PORT}`);
});