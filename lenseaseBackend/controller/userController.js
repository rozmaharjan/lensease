const Users = require('../model/userModel');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const OTP = require('../model/otpModel'); 
const nodemailer = require("nodemailer");


// Function for generating the OTP
const generateOTP = () => {
  return Math.floor(1000 + Math.random() * 9000);
};


//configuring nodemailer
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "adhikarisneha0001@gmail.com",
    pass: "koqycslmnunmthqn",
    // user: process.env.EMAIL_email,
    // pass: process.env.EMAIL_PASSWORD,
  },
});


const resendOTP = async (req, res) => {
  try {
    // Assuming you have the email stored or passed along with the request
    const { email } = req.body;

    // Check if email is provided
    if (!email) {
      return res.status(400).json({ success: false, message: 'Email address is required.' });
    }

    // Find the previous OTP record for the user
    const previousOTP = await OTP.findOne({ email });

    if (!previousOTP) {
      return res.status(404).json({ success: false, message: 'Previous OTP not found.' });
    }

    // Generate a new OTP
    const otp = generateOTP();

    // Send OTP to the stored email address
    await transporter.sendMail({
      from: '"Lensease" <adhikarisneha0001@gmail.com>',
      to: email,
      subject: 'OTP Verification',
      text: `Your OTP for password reset is: ${otp}`,
    });

    // Update the existing OTP record with the new OTP
    previousOTP.otp = otp;
    previousOTP.isUsed = false;
    await previousOTP.save();

    res.status(200).json({ success: true, message: 'OTP resent successfully.' });
  } catch (error) {
    console.error('Error resending OTP:', error);
    res.status(500).json({ success: false, message: 'Failed to resend OTP.' });
  }
};





const sendOTP = async (req, res) => {
  try {
    const { email } = req.body;

    // Find the user by email
    const user = await Users.findOne({ email });

    if (!user) {
      return res
        .status(404)
        .json({ success: false, message: "User not found." });
    }

    // Generate OTP
    const otp = generateOTP();

    // Save OTP to database
    try {
      await OTP.create({ userId: user.id, otp, isUsed: false });
    } catch (error) {
      console.error("Error saving OTP to database:", error);
      return res
        .status(500)
        .json({ success: false, message: "Failed to save OTP." });
    }

    // Send OTP to user's email
    await transporter.sendMail({
      from: '"Lensease" <adhikarisneha0001@gmail.com>',
      to: email,
      subject: "OTP Verification",
      text: `Your OTP for password reset is: ${otp}`,
    });

    // Update user's OTP in the database
    user.otp = otp;
    await user.save();

    console.log("OTP sent to user:", otp);

    res.status(200).json({
      success: true,
      message: "OTP sent to your email.",
    });
  } catch (error) {
    console.error("Error sending OTP:", error);
    res.status(500).json({ success: false, message: "Failed to send OTP." });
  }
};

// Controller function to verify OTP and update password
const verifyOTP = async (req, res) => {
  try {
    const { otp } = req.body;

    // Ensure OTP is provided
    if (!otp) {
      return res.status(400).json({ success: false, message: "OTP is required." });
    }

    // Find the OTP record for the user
    const otpRecord = await OTP.findOne({
      otp,
      isUsed: false,
    });

    if (!otpRecord) {
      return res.status(400).json({ success: false, message: "Invalid or expired OTP." });
    }

    // Mark the OTP as used
    otpRecord.isUsed = true;
    await otpRecord.save();

    res.status(200).json({ success: true, message: "OTP verified successfully." });
  } catch (error) {
    console.error("Error verifying OTP:", error);
    res.status(500).json({ success: false, message: "Failed to verify OTP." });
  }
};



const updatePassword = async (req, res) => {
  try {
    const { newPassword } = req.body;

    // Ensure new password is provided
    if (!newPassword) {
      return res.status(400).json({ success: false, message: "New password is required." });
    }

    // Find the user by the userId associated with the OTP (assuming userId is stored in OTP model)
    const otpRecord = await OTP.findOne({
      OTP,
      isUsed: true, // Ensuring OTP has been used
    });

    if (!otpRecord) {
      return res.status(400).json({ success: false, message: "Invalid or expired OTP." });
    }

    // Find the user by userId from the OTP record
    const user = await Users.findById(otpRecord.userId);

    if (!user) {
      return res.status(404).json({ success: false, message: "User not found." });
    }

    // Encrypt the new password
    const randomSalt = await bcrypt.genSalt(10);
    const encryptedPassword = await bcrypt.hash(newPassword, randomSalt);

    // Updating the user's password with the encrypted password
    user.password = encryptedPassword;

    // Clear OTP-related fields if needed
    user.otp = undefined;
    user.passwordUpdatedWithOTP = true; // Optionally, mark that password has been updated with OTP

    await user.save();

    res.status(200).json({ success: true, message: "Password updated successfully." });
  } catch (error) {
    console.error("Error updating password:", error);
    res.status(500).json({ success: false, message: "Failed to update password." });
  }
};





const register = async (req, res) => {
  console.log(req.body);

  const { firstName, lastName, email, phoneNumber, password, confirmPassword, role, permissions } = req.body;

  if (!firstName ||!lastName ||! email ||! phoneNumber ||!password ||!confirmPassword) {
    return res.json({
      success: false,
      message: 'Please enter all the fields.',
    });
  }

  try {
    const existingUser = await Users.findOne({ email });
    if (existingUser) {
      return res.json({
        success: false,
        message: 'User already exists.',
      });
    }

    const randomSalt = await bcrypt.genSalt(10);
    const encryptedPassword = await bcrypt.hash(password, randomSalt);

    const newUser = new Users({
      firstName,
      lastName,
      email,
      phoneNumber,
      password: encryptedPassword,
      confirmPassword: encryptedPassword,
      role: role || 'user',
      permissions: permissions || ['read', 'write'], 
    });

    await newUser.save();
    res.status(200).json({
      success: true,
      message: 'User created successfully.',
    });
  } catch (error) {
    console.log(error);
    res.status(500).json('Server Error');
  }
};

const loginUser = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: 'Please enter both email and password.',
    });
  }

  try {
    const user = await Users.findOne({ email });
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User does not exist.',
      });
    }

    // Perform password verification
    const isMatched = await bcrypt.compare(password, user.password);
    if (!isMatched) {
      return res.status(401).json({
        success: false,
        message: 'Invalid credentials.',
      });
    }

    // Check if user is admin
    if (user.role !== 'admin') {
      // Normal user login
      const token = jwt.sign(
        { id: user._id, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      return res.status(200).json({
        success: true,
        message: 'User logged in successfully.',
        token,
        userData: user,
      });
    } else {
      // Admin login
      const token = jwt.sign(
        { id: user._id, isAdmin: true, role: user.role },
        process.env.JWT_SECRET,
        { expiresIn: '1h' }
      );

      return res.status(200).json({
        success: true,
        message: 'Admin logged in successfully.',
        token,
        userData: user,
      });
    }
  } catch (error) {
    console.error(error.message);
    res.status(500).json({
      success: false,
      message: 'Server Error',
    });
  }
};




const getAllUsers = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;

    const skip = (page - 1) * limit;

    const users = await Users.find({}).skip(skip).limit(limit);

    res.status(200).json({
      success: true,
      message: 'All users fetched successfully.',
      count: users.length,
      page,
      limit,
      users,
    });
  } catch (error) {
    res.json({
      success: false,
      message: 'Server Error',
      error,
    });
  }
};

const getUserProfile = async (req, res) => {
  try {
    // Extract user ID from the request
    const userId = req.params.userId;

    // Fetch the user's profile data based on the user ID
    const user = await Users.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Exclude the password field from the user object
    const userProfile = {...user.toObject() };
    delete userProfile.password;

    // Return user profile data without the password
    res.status(200).json({
      success: true,
      message: "User profile fetched successfully.",
      userProfile,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};


// edit user profile
const editUserProfile = async (req, res) => {
  try {
    const userId = req.params.userId;
    const user = await Users.findById(userId);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Update specific fields
    user.firstName = req.body.firstName;
    user.lastName = req.body.lastName;
    user.email = req.body.email;
    user.phoneNumber = req.body.phoneNumber;
    user.gender = req.body.gender;
    user.location = req.body.location;

    // Save the updated user profile
    await user.save();

    res.status(200).json({
      success: true,
      message: "User profile updated successfully.",
      updatedUserProfile: user, // Return the updated user object
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Server Error",
      error: error.message,
    });
  }
};

//User Profile Function
const userProfile = async (req, res, next) => {
  const user = await Users.findOne(req.user.id).select("-password");
  console.log(user, "User");
  res.status(200).json({
    success: true,
    user,
  });
};

//delete user profile
const deleteUserAccount = async (req, res) => {
  try {
    const userId = req.params.userId;

    // Check if the user exists
    const user = await Users.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Delete the user
    await Users.findByIdAndDelete(userId);

    res.status(200).json({
      success: true,
      message: 'User account deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Server Error',
      error: error.message,
    });
  }
};


module.exports = {
  resendOTP,
  sendOTP,
  verifyOTP,
  updatePassword,
  register,
  loginUser,
  getAllUsers,
  getUserProfile,
  userProfile,
  editUserProfile,
  deleteUserAccount
};