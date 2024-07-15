const mongoose = require('mongoose');

// Define schema for Checkout
const checkoutSchema = new mongoose.Schema({
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  contactName: {
    type: String,
    required: true
  },
  phoneNumber: {
    type: String,
    required: true
  },
  location: {
    type: String,
    required: true
  },
  note: {
    type: String
  },
  orderSummary: {
    items: [
      {
        productName: { type: String, required: true },
        productQuantity: { type: Number, required: true },
        productPrice: { type: Number, required: true }
      }
    ],
    deliveryCost: { type: Number, required: true },
    totalAmount: { type: Number, required: true }
  },
  paymentMethod: {
    type: String,
    enum: ['cash_on_delivery', 'khalti'],
    required: true
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
});

// Create model from schema
const Checkout = mongoose.model('Checkout', checkoutSchema);

module.exports = Checkout;
