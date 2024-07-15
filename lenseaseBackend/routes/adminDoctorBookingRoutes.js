const express = require("express");
const router = express.Router();
const adminDoctorBookingController = require("../controller/adminDoctorBookingController");
const { authGuard, authGuardAdmin } = require('../middleware/authGuard');
const upload = require('../multer_config'); 

router.post("/create-doctor",upload.single('doctorImage'), authGuard, authGuardAdmin, adminDoctorBookingController.createDoctor);

router.get("/get-doctors",authGuard, adminDoctorBookingController.getDoctors);

router.put("/update-doctor/:id",authGuard, authGuardAdmin,  adminDoctorBookingController.updateDoctor);

router.delete("/delete-doctor/:id", authGuard, authGuardAdmin, adminDoctorBookingController.deleteDoctor);

module.exports = router;
