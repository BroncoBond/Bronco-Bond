const mongoose = require('mongoose');
const db = require('../config/db');
const { Schema } = mongoose;

const userOTPSchema = new Schema({
    userId: {
        type: String
    },
    // One-Time Password
    otp: {
        type: String
    },
    createdAt: {
        type: Date
    },
    expiresAt: {
        type: Date
    },
});

const UserOTP = db.model('UserOTP', userOTPSchema);

module.exports = UserOTP;