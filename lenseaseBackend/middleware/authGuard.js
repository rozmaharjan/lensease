const jwt = require('jsonwebtoken');

const authGuard = (req, res, next) => {
  // Check if auth header is present
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: "Authorization header missing!"
    });
  }

  // Split auth header and get token
  // Format: 'Bearer token_value'
  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Token missing!"
    });
  }

  // Verify token
  try {
    const decodedData = jwt.verify(token, process.env.JWT_SECRET);
    req.user = {
      id: decodedData.id,
      role: decodedData.role,
      permissions: decodedData.permissions
    };
    console.log('Token verified successfully:', decodedData);
    next();
  } catch (error) {
    console.error('Invalid token error:', error);
    return res.status(401).json({
      success: false,
      message: "Invalid token!"
    });
  }
};

const authGuardAdmin = (req, res, next) => {
  // Check if auth header is present
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({
      success: false,
      message: "Authorization header missing!"
    });
  }

  // Split auth header and get token
  // Format: 'Bearer token_value'
  const token = authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({
      success: false,
      message: "Token missing!"
    });
  }

  // Verify token
  try {
    const decodedData = jwt.verify(token, process.env.JWT_SECRET);
    req.user = {
      id: decodedData.id,
      role: decodedData.role,
      permissions: decodedData.permissions
    };
    
    // Ensure permissions array exists and includes 'admin'
    if (!decodedData.isAdmin) {
      return res.status(403).json({
        success: false,
        message: "Permission denied! Only admin can access this resource."
      });
    }
    
    console.log('Admin token verified successfully:', decodedData);
    next();
  } catch (error) {
    console.error('Invalid admin token error:', error);
    return res.status(401).json({
      success: false,
      message: "Invalid token!"
    });
  }
};
module.exports = {
  authGuard,
  authGuardAdmin
};
