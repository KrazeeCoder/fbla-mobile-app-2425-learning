const express = require("express");
const cors = require("cors");
const axios = require("axios");
const admin = require("firebase-admin");

// Load two different service accounts
const serviceAccountFunctions = require("./serviceAccountFunctions.json"); // For Firebase Functions
const serviceAccountAuth = require("./serviceAccountAuth.json"); // For Firebase Auth Token Generation

// Initialize Firebase for Functions execution
admin.initializeApp({
  credential: admin.credential.cert(serviceAccountFunctions),
});

const authAdmin = admin.initializeApp({
  credential: admin.credential.cert(serviceAccountAuth),
}, "authApp"); // Named instance for generating custom tokens

const LinkedinServer = express();
LinkedinServer.use(cors());
LinkedinServer.use(express.json());

// LinkedIn API credentials
const LINKEDIN_CLIENT_ID = "86jqgl7o5plvlv";
const LINKEDIN_CLIENT_SECRET = "WPL_AP1.nYJu1hrZ6kiUbGOZ.0Esfsw==";
const LINKEDIN_REDIRECT_URI = "https://us-central1-voxigo.cloudfunctions.net/myLinkedInServer/auth/linkedin/callback";

// Step 1: Redirect to LinkedIn Login
LinkedinServer.get("/auth/linkedin", (req, res) => {
  const authUrl = `https://www.linkedin.com/oauth/v2/authorization?response_type=code&client_id=${LINKEDIN_CLIENT_ID}&redirect_uri=${encodeURIComponent(LINKEDIN_REDIRECT_URI)}&scope=openid+profile+email`;

  console.log("🔵 Sending client_id to LinkedIn:", LINKEDIN_CLIENT_ID);
  console.log("🔵 Final LinkedIn Auth URL:", authUrl);

  res.redirect(authUrl);
});

// Step 2: Handle LinkedIn Callback, Exchange Code, Fetch Profile, and Authenticate with Firebase
LinkedinServer.get("/auth/linkedin/callback", async (req, res) => {
  console.log("🔵 LinkedIn Callback Query Params:", req.query);
  const { code } = req.query;

  if (!code) {
    console.error("❌ Authorization code missing.");
    return res.status(400).json({ error: "Authorization code missing" });
  }

  try {
    console.log("✅ Received LinkedIn Authorization Code:", code);
    console.log("🔵 Exchanging code for access token...");

    const tokenRes = await axios.post(
      "https://www.linkedin.com/oauth/v2/accessToken",
      new URLSearchParams({
        grant_type: "authorization_code",
        code,
        client_id: LINKEDIN_CLIENT_ID,
        client_secret: LINKEDIN_CLIENT_SECRET,
        redirect_uri: LINKEDIN_REDIRECT_URI,
      }),
      { headers: { "Content-Type": "application/x-www-form-urlencoded" } }
    );

    console.log("✅ LinkedIn Access Token Response:", tokenRes.data);

    const accessToken = tokenRes.data.access_token;
    if (!accessToken) {
      throw new Error("❌ No access token received.");
    }

    console.log("🔵 Fetching LinkedIn Profile...");
    const profileRes = await axios.get("https://api.linkedin.com/v2/userinfo", {
      headers: { Authorization: `Bearer ${accessToken}` },
    });

    console.log("✅ LinkedIn Profile Data:", profileRes.data);

    const linkedInId = profileRes.data.sub;
    const firstName = profileRes.data.given_name || "Unknown";
    const lastName = profileRes.data.family_name || "User";
    const email = profileRes.data.email || "no-email@linkedin.com";

    console.log("🔵 Creating Firebase token using secondary service account...");
    const firebaseToken = await authAdmin.auth().createCustomToken(`linkedin:${linkedInId}`, {
      provider: "linkedin",
      email: email,
      displayName: `${firstName} ${lastName}`,
    });

    console.log("✅ Firebase Custom Token Generated:", firebaseToken);
    console.log("🔵 Redirecting back to app with Firebase token...");

    return res.redirect(`fbla-learning-app://auth?firebaseToken=${firebaseToken}`);
  } catch (error) {
    console.error("❌ LinkedIn Auth Error:", error.response?.data || error.message);
    return res.status(500).json({ error: "LinkedIn Authentication Failed", details: error.response?.data || error.message });
  }
});

// Start the Express server
if (require.main === module) {
  const PORT = process.env.PORT || 8294;
  LinkedinServer.listen(PORT, () => {
    console.log(`🚀 Server running on port ${PORT}`);
  });
}

module.exports = LinkedinServer;
