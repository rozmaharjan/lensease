const router = require("express").Router();
const userController = require("../controller/userController");


//sending the otp
router.post('/send-otp', userController.sendOTP)

router.post('/resend-otp', userController.resendOTP)


//verifying otp and updating the password

router.post('/verify-otp', userController.verifyOTP);
router.post('/update-password', userController.updatePassword);

module.exports = router;