
const express = require('express');
const router = express.Router();
const { authGuard } = require('../middleware/authGuard');
const BookingController = require('../controller/userDoctorBookingController');

router.post('/create-booking', authGuard, BookingController.createBooking);
router.get('/get-bookings',  authGuard, BookingController.getBookings);
router.put('/update-booking/:id', authGuard,  BookingController.updateBooking);
router.delete('/delete-booking/:id', authGuard,  BookingController.deleteBooking);

module.exports = router;