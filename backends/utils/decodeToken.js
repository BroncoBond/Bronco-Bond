const jwt = require('jsonwebtoken');
require('dotenv').config();

class decodeToken {
    static async decodeToken(token) {
        try {
            const decoded = jwt.verify(token, process.env.JWT_KEY);
            return decoded;
          } catch (error) {
            console.error('Error decoding token:', error);
          }
    };
}

  module.exports = decodeToken;