const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require("stripe")("sk_test_51RFh8rRRNxfyNkWbG8a7WVKJArupXd35MNEzksgB0edFBZP6KHOLYYIcSRf75m5oIfDPBLzpZLD6BjlCKDRyN7II00Sw9Xjr4L");

admin.initializeApp();

exports.createPaymentIntent = functions.https.onCall(async (request, context) => {
  try {
    const amount = request.data.amount;
    console.log("Received amount:", amount);

    if (isNaN(amount) || amount <= 0) {
      throw new functions.https.HttpsError('invalid-argument', 'Invalid amount');
    }

    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round(amount * 100),
      currency: 'myr',
    });

    console.log('PaymentIntent created successfully:', paymentIntent.id);

    return {
      clientSecret: paymentIntent.client_secret,
    };
  } catch (error) {
    console.error("Error creating PaymentIntent:", error);
    throw new functions.https.HttpsError('internal', 'PaymentIntent creation failed', error);
  }
});