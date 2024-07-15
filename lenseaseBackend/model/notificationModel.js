// models/Notification.js
const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  title: {
     type: String, 
     required: true 
    },
  message: { 
    type: String, 
    required: true
 },
  date: {
     type: Date, 
     default: Date.now
    },
  read: {
     type: Boolean, 
     default: false 
    }
});

const Notification = mongoose.model('Notification', notificationSchema);

module.exports = Notification
