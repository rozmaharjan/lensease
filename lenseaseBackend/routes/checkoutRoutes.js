const express = require('express');
const router = express.Router();
const checkoutController = require('../controller/checkoutController');
const { authGuard } = require("../middleware/authGuard");

// POST request to create a new checkout
router.post('/', authGuard, checkoutController.createCheckout);

module.exports = router;
