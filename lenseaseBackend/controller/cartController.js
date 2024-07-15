const Cart = require('../model/cartModel');
const Product = require('../model/productModel');
const mongoose = require('mongoose');

const addToCart = async (req, res) => {
  const { productId, quantity, selectedPower } = req.body;

  // Ensure userId is properly extracted from req.user
  const userId = req.user? req.user.id : null;

  if (!userId) {
    return res.status(401).json({
      success: false,
      message: 'Unauthorized'
    });
  }

  try {
    // Fetch product details
    const product = await Product.findById(productId);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    // Calculate total price
    const totalPrice = product.productPrice * quantity;

    // Create new cart item
    const newCartItem = new Cart({
      userId, // Ensure userId is properly assigned
      productId,
      quantity,
      selectedPower,
      totalPrice
    });

    // Save cart item to database
    await newCartItem.save();

    res.json({
      success: true,
      message: 'Product added to cart successfully',
      cartItem: newCartItem
    });
  } catch (error) {
    console.error('Error adding to cart:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

const getAllCartItems = async (req, res) => {
  const userId = req.user.id; // Assuming userId is available in req.user after authentication

  try {
    const cartItems = await Cart.find({ userId }).populate('productId');
    res.json({
      success: true,
      cartItems
    });
  } catch (error) {
    console.error('Error fetching cart items:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

const getCartItemById = async (req, res) => {
  const { cartItemId } = req.params;

  try {
    const cartItem = await Cart.findById(cartItemId).populate('productId');
    if (!cartItem) {
      return res.status(404).json({
        success: false,
        message: 'Cart item not found'
      });
    }

    res.json({
      success: true,
      cartItem
    });
  } catch (error) {
    console.error('Error fetching cart item:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

const removeCartItem = async (req, res) => {
  const productId = req.params.productId;
  const userId = req.user.id;

  console.log(`Removing cart item with productId: ${productId} and userId: ${userId}`);

  try {
    // Use findOneAndDelete instead of findOneAndRemove
    const cartItem = await Cart.findOneAndDelete({ userId, 'products._id': productId });

    if (!cartItem) {
      console.log(`Cart item not found with productId: ${productId} and userId: ${userId}`);
      return res.status(404).json({ success: false, message: 'Cart item not found' });
    }

    console.log(`Cart item removed successfully`);
    res.json({ success: true, message: 'Cart item removed' });
  } catch (error) {
    console.error(`Error removing cart item: ${error}`);
    res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

const updateCartItemQuantity = async (req, res) => {
  try {
      const { cartItemId } = req.params;
      const { quantity } = req.body;

      // Find the cart item by ID and update quantity
      const updatedCartItem = await Cart.findByIdAndUpdate(
          cartItemId,
          { quantity },
          { new: true }
      );
      if (!updatedCartItem) {
          return res.status(404).json({ message: "Cart item not found" });
      }

      res.status(200).json({ message: "Cart item quantity updated successfully", updatedCartItem });
  } catch (error) {
      console.error("Error updating cart item quantity:", error);
      res.status(500).json({ message: "Internal server error" });
  }
};




module.exports = {
 addToCart,
 getAllCartItems,
 getCartItemById,
 removeCartItem,
 updateCartItemQuantity
};
