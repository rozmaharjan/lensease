const express = require('express');
const router = express.Router();
const LensPower = require('../model/lensModel');

// Add a new lens power
const addLense = async (req, res) => {
    const { power } = req.body;
  
    try {
      const newLensPower = new LensPower({ power });
      await newLensPower.save();
      res.json({
        success: true,
        message: 'Lens powers added successfully',
        lensPower: newLensPower
      });
    } catch (error) {
      console.error('Error adding lens powers:', error);
      res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

// Get all lens powers
const getAllLenses = async (req, res) => {
  try {
    const lensPowers = await LensPower.find({});
    res.json({
      success: true,
      lensPowers
    });
  } catch (error) {
    console.error('Error fetching lens powers:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
}

// Delete a lens power
const deleteLense = async (req, res) => {
  const { id } = req.params;

  try {
    await LensPower.findByIdAndDelete(id);
    res.json({
      success: true,
      message: 'Lens power deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting lens power:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error'
    });
  }
}

module.exports = {
    addLense,
    getAllLenses,
    deleteLense
}
