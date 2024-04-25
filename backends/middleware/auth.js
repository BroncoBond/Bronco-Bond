const jwt = require('jsonwebtoken');
const User = require('../model/user.model');

exports.isAuth = async (req, res, next) => {
  const token = req.cookies.jwt;
  console.log('Token:', token);
  
  if (token) {
    try {
      const decode = jwt.verify(token, process.env.JWT_KEY);
      console.log('Decoded:', decode);

      const user = await User.findById(decode.data._id);
      console.log('User:', user);

      if (!user) {
        return res.json({ status: false, message: 'unauthorized access!' });
      }

      req.user = user;
      next();
    } catch (error) {
      if (error.name === 'JsonWebTokenError') {
        return res.json({ status: false, message: 'unauthorized access!' });
      }
      if (error.name === 'TokenExpiredError') {
        return res.json({
          status: false,
          message: 'session expired, try sign in again!',
        });
      }

      res.json({ status: false, message: 'Internal server error!' });
    }
  } else {
    res.json({ status: false, message: 'unauthorized access!' });
  }
};