const Checkout = require('../model/checkoutModel'); // Correct the path if necessary

// Create a new checkout
const createCheckout = async (req, res) => {
  const {
    userId,
    contactName,
    phoneNumber,
    location,
    note,
    orderSummary,
    paymentMethod,
  } = req.body;

  try {
    const newCheckout = new Checkout({
      userId,
      contactName,
      phoneNumber,
      location,
      note,
      orderSummary,
      paymentMethod,
    });

    await newCheckout.save();

    res.status(201).json({
      success: true,
      message: "Checkout created successfully",
      checkout: newCheckout,
    });
  } catch (error) {
    console.error("Error creating checkout:", error);
    res.status(500).json({
      success: false,
      message: "Internal server error",
    });
  }
};

module.exports = {
  createCheckout,
};
