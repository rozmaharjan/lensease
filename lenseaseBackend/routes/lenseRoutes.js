const express = require('express');
const router = express.Router();
const lenseController = require('../controller/lensPowerController');
const { authGuard, authGuardAdmin } = require('../middleware/authGuard');

// POST /api/lenspowers/add
router.post('/add', authGuard, authGuardAdmin, lenseController.addLense);

// GET /api/lenspowers/get_lense
router.get('/get_lense', lenseController.getAllLenses);

// DELETE /api/lenspowers/delete_lense/:id
router.delete('/delete_lense/:id', authGuard, authGuardAdmin, lenseController.deleteLense);

module.exports = router;
