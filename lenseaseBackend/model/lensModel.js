const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const lensPowerSchema = new Schema({
  power: {
    type: [Number], // Accepts an array of numbers
    required: true
  }
});

module.exports = mongoose.model('LensPower', lensPowerSchema);
