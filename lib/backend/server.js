// server.js
const express = require('express');
const axios = require('axios');
const cors = require('cors');
const app = express();

app.use(cors());
app.use(express.json());

// ---- CONFIG ----
const consumerKey = 'RGzApugJpGgE7djnSALpG8e8d9q5GWizfRCYscsD0nJA9PGD';
const consumerSecret = 'ew7LOndFqUlyM0DravTOxGyyE9ANAyRyQZ6kBG7AbfGz7R3U6aKN6Ouxq5FgwAdE';
const shortCode = '174379';
const passkey = 'bfb279f9aa9bdbcf158e97dd0e5dcd56c9f6e5a4f6b4c2f0e6d1c1f2e1b7d0';
const callbackURL = 'https://supercultivated-limonitic-adelia.ngrok-free.dev'; // your Ngrok

// ---- STK Push route ----
app.post('/stkpush', async (req, res) => {
  const { phone, amount } = req.body;

  try {
    // 1️⃣ Get OAuth token
    const auth = Buffer.from(`${consumerKey}:${consumerSecret}`).toString('base64');
    const tokenResponse = await axios.get(
      'https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials',
      { headers: { Authorization: `Basic ${auth}` } }
    );
    const token = tokenResponse.data.access_token;

    // 2️⃣ Generate password
    const timestamp = new Date().toISOString().replace(/[-:T.Z]/g, '').slice(0, 14);
    const password = Buffer.from(shortCode + passkey + timestamp).toString('base64');

    // 3️⃣ STK Push request
    const stkRequest = {
      BusinessShortCode: shortCode,
      Password: password,
      Timestamp: timestamp,
      TransactionType: 'CustomerPayBillOnline',
      Amount: amount,
      PartyA: phone,
      PartyB: shortCode,
      PhoneNumber: phone,
      CallBackURL: callbackURL,
      AccountReference: 'Test123',
      TransactionDesc: 'Mobimart payment'
    };

    const stkResponse = await axios.post(
      'https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest',
      stkRequest,
      { headers: { Authorization: `Bearer ${token}` } }
    );

    console.log('STK Response:', stkResponse.data);
    res.json(stkResponse.data);
  } catch (err) {
    console.error('STK Push Error:', err.response?.data || err.message);
    res.status(500).json({ error: 'Failed to initiate STK Push' });
  }
});

// ---- Callback route ----
app.post('/callback', (req, res) => {
  console.log('MPESA CALLBACK:', JSON.stringify(req.body, null, 2));
  res.status(200).json({ ResultCode: 0, ResultDesc: 'Accepted' });
});

// ---- Start server ----
const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
