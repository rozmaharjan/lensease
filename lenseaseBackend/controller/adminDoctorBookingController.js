const AdminDoctorBookingModel = require('../model/adminDoctorBookingModel');
const cloudinary = require('cloudinary').v2; 

// Create doctor
const createDoctor = async (req, res) => {
  const { doctorName, doctorDescription, availableDates, availableTimes } = req.body;
  const doctorImage = req.file;

  try {
    // Validate required fields
    if (!doctorName || !doctorDescription || !availableDates || !availableTimes || !doctorImage) {
      return res.status(400).json({
        success: false,
        message: "Please fill all the fields and upload an image."
      });
    }

    // Upload image to Cloudinary
    const uploadedImage = await cloudinary.uploader.upload(doctorImage.path, {
      folder: "Doctors",
      crop: "scale"
    });

    // Create new doctor
    const newDoctor = new AdminDoctorBookingModel({
      doctorName,
      doctorDescription,
      image: uploadedImage.secure_url,
      availableDates,
      availableTimes,
    });

    // Save doctor to database
    await newDoctor.save();

    res.status(200).json({
      success: true,
      message: 'Doctor created successfully',
      doctor: newDoctor
    });
  } catch (error) {
    console.error('Error creating doctor:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};
// Get all doctors
const getDoctors = async (req, res) => {
  try {
    const doctors = await AdminDoctorBookingModel.find();
    res.json({
      success: true,
      message: 'Doctors fetched successfully',
      doctors
    });
  } catch (error) {
    console.error('Error fetching doctors:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Update doctor
const updateDoctor = async (req, res) => {
  const { id } = req.params;
  const { doctorName, doctorDescription, image, availableDates, availableTimes } = req.body;

  try {
    const doctor = await AdminDoctorBookingModel.findByIdAndUpdate(id, {
      doctorName,
      doctorDescription,
      image,
      availableDates,
      availableTimes
    }, { new: true });

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found'
      });
    }

    res.json({
      success: true,
      message: 'Doctor updated successfully',
      doctor
    });
  } catch (error) {
    console.error('Error updating doctor:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

// Delete doctor
const deleteDoctor = async (req, res) => {
  const { id } = req.params;

  try {
    await AdminDoctorBookingModel.findByIdAndRemove(id);
    res.json({
      success: true,
      message: 'Doctor deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting doctor:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
};

module.exports = {
  createDoctor,
  getDoctors,
  updateDoctor,
  deleteDoctor
};