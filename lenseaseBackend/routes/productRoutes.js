const express = require('express');
const router = express.Router();
const productController = require("../controller/productController");
const { authGuard, authGuardAdmin } = require('../middleware/authGuard');
const upload = require('../multer_config'); 


router.post('/create_product', upload.single('productImage'), productController.createProduct);



// Get all products (GET)
router.get('/get_products', productController.getProducts);

// Get a single product by ID (GET)
router.get('/get_product/:id', productController.getSingleProduct);

// Update a product by ID (PUT)
router.put('/update_product/:id', authGuard, authGuardAdmin, productController.updateProduct);

// Delete a product by ID (DELETE)
router.delete('/delete_product/:id', authGuard, authGuardAdmin, productController.deleteProduct);

module.exports = router;
