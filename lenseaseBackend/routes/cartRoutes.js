const express = require('express');
const router = express.Router();
const cartController = require('../controller/cartController');
const { authGuard } = require("../middleware/authGuard");


router.post('/addcart', authGuard, cartController.addToCart);

router.get('/getcart', authGuard, cartController.getAllCartItems);

router.get('/getcart/:cartItemId', authGuard, cartController.getCartItemById);

router.put('/:cartItemId/updateQuantity', authGuard, cartController.updateCartItemQuantity);

router.delete('/removecart/:cartItemId', authGuard, cartController.removeCartItem);

module.exports = router;