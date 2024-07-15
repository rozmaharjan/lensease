const mongoose = require('mongoose');
const cloudinary = require("cloudinary").v2;
const Products = require("../model/productModel");
const LensPower = require('../model/lensModel');

const createProduct = async (req, res) => {
  const { productName, productPrice, productDescription, lensPowers } = req.body;
  const productImage = req.file;

  // Parse lensPowers from string to array of numbers
  let parsedLensPowers;
  try {
    parsedLensPowers = JSON.parse(lensPowers);
    if (!Array.isArray(parsedLensPowers)) {
      throw new Error("Lens powers must be provided as an array.");
    }
    if (!parsedLensPowers.every(power => typeof power === 'number')) {
      throw new Error("Lens powers must be numbers.");
    }
  } catch (error) {
    console.error("Error parsing lensPowers:", error);
    return res.status(400).json({
      success: false,
      message: "Invalid lens powers format."
    });
  }

  try {
    // Validate required fields
    if (!productName || !productPrice || !productDescription || !productImage) {
      return res.status(400).json({
        success: false,
        message: "Please fill all the fields and upload an image."
      });
    }

    // Upload image to Cloudinary
    const uploadedImage = await cloudinary.uploader.upload(productImage.path, {
      folder: "Products",
      crop: "scale"
    });

    // Create new product with parsed lensPowers
    const newProduct = new Products({
      productName,
      productPrice,
      productDescription,
      lensPowers: parsedLensPowers,
      productImageUrl: uploadedImage.secure_url
    });

    // Save product to database
    await newProduct.save();

    res.json({
      success: true,
      message: "Product created successfully",
      product: newProduct
    });

  } catch (error) {
    console.error("Error creating product:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error"
    });
  }
};



// Get all products
const getProducts = async (req, res) => {
  try {
    const allProducts = await Products.find({});
    res.json({
      success: true,
      message: "All Products fetched successfully!",
      products: allProducts
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: "Internal server error"
    });
  }
};

// Fetch single product
const getSingleProduct = async (req, res) => {
  const ProductId = req.params.id;

  // Check if the ProductId is a valid ObjectId
  if (!mongoose.Types.ObjectId.isValid(ProductId)) {
    return res.status(400).json({
      success: false,
      message: 'Invalid Product ID format'
    });
  }

  try {
    const singleProduct = await Products.findById(ProductId);
    if (!singleProduct) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    res.json({
      success: true,
      message: 'Single Product fetched successfully!',
      product: singleProduct
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Update product
const updateProduct = async (req, res) => {
  const { productName, productPrice, productDescription, lensPower } = req.body;
  const productImage = req.file; // Use req.file for single file upload

  // Validate required fields
  if (!productName || !productPrice || !productDescription) {
    return res.status(400).json({
      success: false,
      message: "Required fields are missing!"
    });
  }

  try {
    let updatedData = {
      productName,
      productPrice,
      productDescription
    };

    // Validate lensPower if provided
    if (lensPower !== undefined && lensPower !== null) {
      const validLensPower = await LensPower.findOne({ power: parseFloat(lensPower) });
      if (!validLensPower) {
        return res.status(400).json({
          success: false,
          message: "Invalid lens power selected"
        });
      }
      updatedData.lensPower = parseFloat(lensPower);
    }

    // Check if there is an image
    if (productImage) {
      // Upload image to Cloudinary
      const uploadedImage = await cloudinary.uploader.upload(productImage.path, {
        folder: "Products",
        crop: "scale"
      });
      updatedData.productImageUrl = uploadedImage.secure_url;
    }

    // Find Product and update
    const ProductId = req.params.id;
    const updatedProduct = await Products.findByIdAndUpdate(ProductId, updatedData, { new: true });

    res.json({
      success: true,
      message: "Product updated successfully!",
      product: updatedProduct
    });

  } catch (error) {
    console.error("Error updating product:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error"
    });
  }
};

// Delete product
const deleteProduct = async (req, res) => {
  const ProductId = req.params.id;

  try {
    await Products.findByIdAndDelete(ProductId);
    res.json({
      success: true,
      message: "Product deleted successfully!"
    });

  } catch (error) {
    console.error("Error deleting product:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error"
    });
  }
};

module.exports = {
  createProduct,
  getProducts,
  getSingleProduct,
  updateProduct,
  deleteProduct
};
