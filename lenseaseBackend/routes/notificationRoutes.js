// routes/notificationRoutes.js
const express = require('express');
const router = express.Router();
const notificationController = require('../controller/notificationsController');
const { authGuard, authGuardAdmin } = require('../middleware/authGuard');

router.post('/add-notification', authGuardAdmin, notificationController.addNotification);
router.get('/get-notifications', authGuard, notificationController.getNotifications);

module.exports = router;
