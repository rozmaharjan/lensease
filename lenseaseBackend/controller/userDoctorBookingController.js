const mongoose = require('mongoose');
const UserBookingModel = require('../model/userDoctorBookingModel');

// Create booking
const createBooking = async (req, res) => {
  const { doctorId, date, time } = req.body;

  try {
    // Validate required fields
    if (!doctorId || !date || !time) {
      return res.status(400).json({
        success: false,
        message: "Please fill all the fields."
      });
    }

    // Validate doctorId
    if (!mongoose.Types.ObjectId.isValid(doctorId)) {
      return res.status(400).json({
        success: false,
        message: "Invalid doctorId."
      });
    }

    // Create new booking
    const newBooking = new UserBookingModel({
      doctorId,
      date,
      time,
      userId: req.user.id,
    });

    // Save booking to database
    await newBooking.save();

    res.status(200).json({
      success: true,
      message: 'Booking created successfully',
      booking: newBooking
    });
  } catch (error) {
    console.error('Error creating booking:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};



// Get all bookings
const getBookings = async (req, res) => {
  try {
    const bookings = await UserBookingModel.find({ userId: req.user.id });
    res.json({
      success: true,
      message: 'Bookings fetched successfully',
      bookings
    });
  } catch (error) {
    console.error('Error fetching bookings:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Update booking
const updateBooking = async (req, res) => {
  const { id } = req.params;
  const { doctorId, date, time } = req.body;

  try {
    const booking = await UserBookingModel.findByIdAndUpdate(id, {
      doctorId,
      date,
      time
    }, { new: true });

    if (!booking) {
      return res.status(404).json({
        success: false,
        message: 'Booking not found'
      });
    }

    res.json({
      success: true,
      message: 'Booking updated successfully',
      booking
    });
  } catch (error) {
    console.error('Error updating booking:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Delete booking
const deleteBooking = async (req, res) => {
  const { id } = req.params;

  try {
    await UserBookingModel.findByIdAndRemove(id);
    res.json({
      success: true,
      message: 'Booking deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting booking:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

module.exports = {
  createBooking,
  getBookings,
  updateBooking,
  deleteBooking
};