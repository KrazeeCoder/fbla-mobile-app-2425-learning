
const functions = require("firebase-functions/v1");
const server = require('./server'); // Adjust this path if server.js is at a different relative location

// Export the Express app as a Firebase Function
exports.myLinkedInServer = functions.https.onRequest(server);
