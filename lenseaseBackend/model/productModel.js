const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  productName: {
    type: String,
    required: true
  },
  productPrice: {
    type: Number,
    required: true
  },
  productDescription: {
    type: String,
    required: true
  },
  lensPowers: {
    type: [Number],
    required: false
  },
  productImageUrl: {
    type: String,
    required: true
  }
});

// Log current indexes before attempting to modify
const Product = mongoose.model('Products', productSchema);

// Product.collection.getIndexes().then(indexes => {
//   console.log('Current indexes:', indexes);
// });

// // Drop the existing index on lensPowers if it exists
// Product.collection.dropIndex('lensPowers_1', function(err, result) {
//   if (err) {
//     console.error('Error dropping index:', err);
//   } else {
//     console.log('Index dropped successfully:', result);
//   }
// });

// // Log indexes after dropping index
// Product.collection.getIndexes().then(indexes => {
//   console.log('Indexes after dropping index:', indexes);
// });

module.exports = Product;
