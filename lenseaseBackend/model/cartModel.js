const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
  productId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Products',
    required: true
  },
  quantity: {
    type: Number,
    required: true
  },
  selectedPower: {
    type: Number,
    required: true
  },
  totalPrice: {
    type: Number,
    required: true
  },
  userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User', 
    required: true
  }
});

const Cart = mongoose.model('Cart', cartSchema);

module.exports = Cart;
