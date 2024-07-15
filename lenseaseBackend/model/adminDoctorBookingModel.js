const mongoose = require('mongoose');

const adminDoctorBookingSchema = new mongoose.Schema({
  doctorName: {
    type: String,
    required: true,
  },
  doctorDescription: {
    type: String,
    required: true,
  },
  image: {
    type: String,
    required: true,
  },
  availableDates: [
    {
      type: Date,
      required: true,
    },
  ],
  availableTimes: [
    {
      type: String,
      required: true,
    },
  ],
});

module.exports = mongoose.model('AdminDoctorBooking', adminDoctorBookingSchema);