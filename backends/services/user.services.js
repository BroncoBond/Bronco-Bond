const User = require('../model/user.model');
const jwt = require('jsonwebtoken');
const generateToken = require('../utils/generateToken');

// Used for OTP
const UserOTP = require('../model/userOTP.model');
const nodemailer = require('nodemailer');
const bcrypt = require('bcrypt');
require('dotenv').config();

class UserService {
  static async registerUser(email, username, password) {
    const createUser = new User({ email, username, password });
    try {
      const newUser = await createUser.save();
      // Log the newly created user
      console.log('User registered:', newUser);

      return newUser;
    } catch (error) {
      if (error.name === 'MongoError' && error.code === 11000) {
        // Duplicate key error
        if (error.keyPattern && error.keyPattern.email) {
          // Duplicate email error
          throw new DuplicateKeyError('Email');
        } else if (error.keyPattern && error.keyPattern.username) {
          // Duplicate username error
          throw new DuplicateKeyError('Username');
        }
      }
      // For other errors, log and rethrow
      console.error('Error during user registration:', error);
      throw new CustomError(error.message, 500);
    }
  }

  static async sendUserOTP(_id, email) {
    let transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: process.env.AUTH_EMAIL,
        pass: process.env.AUTH_PASS,
      },
    });

    transporter.verify((error, success) => {
        if (error) {
            console.log(error);
        } else {
            console.log('Ready for messages');
            console.log(success);
        }
    });

    try {
      const otp = `${Math.floor(100000 + Math.random() * 900000)}`; // 6 digit code between 000000-999999

      const mailOptions = {
        from: process.env.AUTH_EMAIL,
        to: email,
        subject: 'Verify Your Email For BroncoBond!',
        html: `<p>Enter <b>${otp}</b> in the app to verify your email address for BroncoBond.</p><p>This code <b>expires 1 hour</b> from creation.</p>`,
      };

      const saltRounds = 10;
      const hashedOTP = await bcrypt.hash(otp, saltRounds);
      const newUserOTP = await new UserOTP({
        userId: _id,
        otp: hashedOTP,
        createdAt: Date.now(),
        expiresAt: Date.now() + 3600000 // 1 hour (ms)
      });

      await newUserOTP.save();
      await transporter.sendMail(mailOptions);
      return {
        status: 'PENDING',
        message: 'Verification OTP email sent.',
        data: {
            userId: _id,
            email,
        }
      };
    } catch (error) {
        return {
            status: 'FAILED',
            message: error.message,
        };
    }
  }

  static async checkUser(email) {
    try {
      console.log('Checking User: ' + email);
      return await User.findOne({ email });
    } catch (error) {
      throw error;
    }
  }

  static async acceptBondRequest(recipientID, senderID) {
    try {
      if (recipientID === senderID) {
        return {
          status: 400,
          message: 'A user cannot send a bond request to themselves',
        };
      }

      let recipient = await User.findById(recipientID);
      let sender = await User.findById(senderID);

      if (
        !recipient.bonds.includes(senderID) &&
        !sender.bonds.includes(recipientID)
      ) {
        if (sender.bondRequestsReceived.includes(recipientID)) {
          sender.bondRequestsReceived.pull(recipientID);
        }
        if (sender.bondRequestsSent.includes(recipientID)) {
          sender.bondRequestsSent.pull(recipientID);
        }
        sender.bonds.push(recipientID);
        sender.numOfBonds += 1;
        await sender.save();

        if (recipient.bondRequestsReceived.includes(senderID)) {
          recipient.bondRequestsReceived.pull(senderID);
        }
        if (recipient.bondRequestsSent.includes(senderID)) {
          recipient.bondRequestsSent.pull(senderID);
        }
        recipient.bonds.push(senderID);
        recipient.numOfBonds += 1;
        await recipient.save();

        return { status: 200, message: 'Bond request accepted' };
      } else {
        return {
          status: 403,
          message: 'You are already friended with this user',
        };
      }
    } catch (error) {
      console.log(error);
      return { status: 500, message: error };
    }
  }
}

class CustomError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
  }
}

class DuplicateKeyError extends CustomError {
  constructor(field) {
    super(`${field} already exists`, 400);
    this.field = field;
  }
}

module.exports = UserService;
