const UserService = require('../services/user.services');
const generater = require('../utils/generateToken');
const decoder = require('../utils/decodeToken');
const bcrypt = require('bcrypt');
const User = require('../model/user.model');
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
require('dotenv').config();

const UserOTP = require('../model/userOTP.model');
const Calendar = require('../model/calendar.model');

// Used for functions that involve (un)following organizations
const Organization = require('../model/organization.model');

// Used for functions that involve (un)interest events
const Event = require('../model/event.model');

const extractAndDecodeToken = async (req) => {
  const token = req.headers.authorization.split(' ')[1];

  if (!token) {
    throw new Error('Authorization fail!');
  }

  try {
    const decoded = await decoder.decodeToken(token);
    return decoded;
  } catch (err) {
    if (err instanceof jwt.TokenExpiredError) {
      throw new Error('Token expired!');
    } else {
      throw new Error('Invalid token!');
    }
  }
};

// Separate line to export so the function can still be used for user methods
exports.extractAndDecodeToken = extractAndDecodeToken;

exports.register = async (req, res, next) => {
  try {
    const { email, username, password } = req.body;
    if (!/@cpp\.edu\s*$/.test(email)) {
      res.status(400).json({ status: false, error: 'Invalid Cpp Email' });
    }
    console.log('Received registration data');

    const newUser = await UserService.registerUser(email, username, password);
    console.log('User created:', newUser);

    // Creating the user model
    try {
      let tokenData = { _id: newUser._id };
      token = await generater.generateToken(tokenData, res, '10m');
      await User.findByIdAndUpdate(tokenData, {
        tokens: [{ token, signedAt: Date.now().toString() }],
      });
    } catch (err) {
      console.log('Error generating token');
      // If generating the token fails, delete the user
      await User.findByIdAndDelete(newUser._id);
      throw err;
    }

    // Creating the user's calendar
    try {
      const calendar = await UserService.createCalendar(newUser._id);
      await User.findByIdAndUpdate(newUser._id, { calendar: calendar });
    } catch (err) {
      console.log('Error creating calendar');
      await User.findByIdAndDelete(newUser._id);
      throw err;
    }

    // Generating OTP
    try {
      await UserService.sendUserOTP(newUser._id, newUser.email);
    } catch (err) {
      console.log('Error sending OTP email');
      await User.findByIdAndDelete(newUser._id);
      throw err;
    }

    // Log the success response
    console.log('User registered successfully:', newUser);

    res.json({
      status: true,
      success: 'User Registered Successfully',
      _id: newUser._id,
      token: token,
    });
  } catch (error) {
    console.log('Error occurred: ' + error.message);

    // Log specific errors
    if (error.message.includes('E11000')) {
      console.error('Error Duplicate Email/Username:', error.message);
      return res
        .status(400)
        .json({ status: false, error: 'Duplicate email/username' });
    }

    // Log any other errors
    console.error('Error during registration');

    // Send a generic error response
    res.status(500).json({ status: false, error: 'Internal Server Error' });
  }
};

exports.verifyOTP = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const currentUserId = currentUser.data._id;
    const otp = req.body.otp;

    if (!otp) {
      return res.status(400).json({ error: 'Please provide the OTP.' });
    }

    const userOTPRecords = await UserOTP.find({
      userId: currentUserId,
    });

    console.log(userOTPRecords);

    if (!userOTPRecords) {
      return res.status(400).json({
        error: 'No OTP found. Perhaps the account is already verified?',
      });
    }

    const expiresAt = new Date(userOTPRecords[0].expiresAt);
    const hashedOTP = userOTPRecords[0].otp;

    if (expiresAt < Date.now()) {
      await UserOTP.deleteMany({ userId: currentUserId });
      return res.status(400).json({
        error: 'Code has expired. Please request another OTP.',
      });
    }

    const validOTP = await bcrypt.compare(otp, hashedOTP);

    if (!validOTP) {
      return res.status(400).json({
        error: 'Invalid, please double-check your OTP.',
      });
    }

    await User.findByIdAndUpdate(
      currentUserId,
      {
        $set: {
          verified: true,
        },
      },
      { new: true }
    );
    await UserOTP.deleteMany({ userId: currentUserId });
    return res.status(200).json({ message: 'OTP verified successfully.' });
  } catch (error) {
    console.error('Error during OTP verification: ', error);
    return res
      .status(500)
      .json({ error: 'An error occurred during OTP verification.' });
  }
};

exports.resendOTP = async (req, res) => {
  try {
    const {
      data: { _id: currentUserId, verified: checkVerify },
    } = await extractAndDecodeToken(req);
    const { email: currentUserEmail } = await User.findById(currentUserId);
    if (checkVerify) {
      return res.status(500).json({ error: 'User already verified' });
    }

    await UserOTP.deleteMany({ userId: currentUserId });
    await UserService.sendUserOTP(currentUserId, currentUserEmail);
    return res.json({
      status: true,
      success: 'OTP resent successfully.',
    });
  } catch (error) {
    console.error('Error during OTP resend: ', error);
    return res
      .status(500)
      .json({ error: 'An error occurred during OTP resend.' });
  }
};

// This function is used to log in a user
exports.login = async (req, res, next) => {
  try {
    // Extract the email and password from the request body
    const { email, password } = req.body;
    const { staySignedIn } = req.body;
    console.log(staySignedIn);

    // Try to find a user with the given email
    const user = await UserService.checkUser(email);

    // If no user is found, throw an error
    if (!user || !user._id) {
      throw new Error('User does not exist!');
    } else {
      console.log('User found!');
    }

    // Check if the provided password matches the user's password
    const isMatch = await user.comparePassword(password);
    // If the passwords don't match, throw an error
    if (isMatch === false) {
      throw new Error('Password Invalid');
    }

    // If the passwords match, create a token for the user
    let tokenData = { _id: user._id };

    let token;
    // Generate the token
    if (!staySignedIn) {
      token = await generater.generateToken(tokenData, res, '1h');
    } else {
      token = await generater.generateToken(tokenData, res);
    }
    // Replace the user's existing tokens with new token
    await User.findByIdAndUpdate(user._id, {
      tokens: [{ token, signedAt: Date.now().toString() }],
    });

    // If the token was successfully generated, return a 200 status with the token
    res.status(200).json({ status: true, token: token });
  } catch (error) {
    // If there's an error during login, log the error and pass it to the next middleware
    console.error('Error during login: ', error);
    next(error);
  }
};

// This function is used to search for a user by their username
exports.searchUserByUsername = async (req, res) => {
  // Extract the username from the request query
  try {
    const extractedToken = await extractAndDecodeToken(req);
    const currentUserId = extractedToken.data._id;
    console.log(currentUserId);
    const { username } = req.query;

    // Check if a username was provided
    if (!username) {
      return res
        .status(400)
        .json({ error: 'You must provide a username to search.' });
    }

    try {
      // Create a case-insensitive regular expression to search for usernames that contain the given input
      const regex = new RegExp(username, 'i');

      // Try to find users whose username matches the regular expression
      const users = await User.find({
        username: { $regex: regex },
        _id: { $ne: currentUserId },
      }).select('-password -email');

      // If users are found, return the users data
      if (users.length > 0) {
        return res.status(200).json(users);
      }

      // If no users are found, return a 404 status with an error message
      return res.status(404).json({ error: 'No users found' });
    } catch (err) {
      // If there's an error searching for the users, return a 500 status with the error
      console.error('Error searching for users:', err);
      return res
        .status(500)
        .json({ error: 'An error occurred while searching for users.' });
    }
  } catch (error) {
    console.error('Error during token extraction and decoding: ', error);
    return res.status(401).json({ status: false, message: error.message });
  }
};

exports.getBondList = async (req, res) => {
  try {
    const currentUserId = (await extractAndDecodeToken(req)).data._id;
    const currentUserBonds = await User.findById(currentUserId).select('bonds');
    return res.status(200).json({ bonds: currentUserBonds.bonds });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ error: 'An error occurred while fetching the friend list' });
  }
};

exports.getFollowedOrganizations = async (req, res) => {
  try {
    const currentUserId = (await extractAndDecodeToken(req)).data._id;
    const currentFollowedOrganizations = await User.findById(
      currentUserId
    ).select('followedOrganizations');
    return res.status(200).json({
      'followedOrganizations:':
        currentFollowedOrganizations.followedOrganizations,
    });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ error: 'An error occured while fetching the organizations' });
  }
};

exports.getById = async (req, res) => {
  const currentUserId = (await extractAndDecodeToken(req)).data._id;
  const bodyId = req.body._id;
  let user;
  try {
    user = await User.findById(bodyId).select('-email -password');
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
  if (!user) {
    return res.status(404).json({ message: 'No User Found' });
  }
  return res.status(200).json({ user });
};

// DEVELOPMENT BUILD ONLY
if (process.env.NODE_ENV === 'development') {
  exports.getAllUserIds = async (req, res) => {
    try {
      const users = await User.find({}, '_id'); // fetch only the _id field for all users
      const _id = users.map((user) => user._id); // extract the _id from each user
      return res.status(200).json(_id); // return the array of user IDs
    } catch (error) {
      console.error('Error fetching user IDs:', error);
      return res.status(500).json({ message: error.message });
    }
  };
  exports.getAllUserData = async (req, res) => {
    try {
      const users = await User.find({}).select('-password -profilePicture'); // fetch the user data for all users
      return res.status(200).json(users); // return the array of user data
    } catch (error) {
      console.error('Error fetching user IDs:', error);
      return res.status(500).json({ message: error.message });
    }
  };
}

// This function is used to update a user's information
exports.updateUserInfo = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;
    const givenUserId = req.body._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    // Fetch the user
    const user = await User.findById(givenUserId);

    // Check if the user is authorized to update the account
    if (givenUserId === tokenUserId || isAdmin) {
      // If a new password is provided, hash it before storing it
      if (req.body.password) {
        const salt = await bcrypt.genSalt(10);
        req.body.password = await bcrypt.hash(req.body.password, salt);
      }
      // If a new username is provided in the request body
      if (req.body.username) {
        // Try to find a user with the new username
        const existingUser = await User.findOne({
          username: req.body.username,
        });
        if (existingUser) {
          // If a user with the new username already exists, return a 400 status with an error message
          return res.status(400).json({ error: 'Username already exists' });
        }
      }
      const {
        username,
        password,
        profilePicture,
        graduationDate,
        descriptionMajor,
        descriptionMinor,
        descriptionBio,
        fullName,
        prefName,
        gender,
        pronouns,
      } = req.body;

      // Log the data that will be used to update the user
      console.log('Updating user with data');

      // Try to update the user with the given ID and data
      const updatedUser = await User.findByIdAndUpdate(
        givenUserId,
        {
          $set: {
            username,
            password,
            profilePicture,
            graduationDate,
            descriptionMajor,
            descriptionMinor,
            descriptionBio,
            fullName,
            prefName,
            gender,
            pronouns,
          },
        },
        { new: true }
      ); // Add { new: true } to return the updated user

      if (!updatedUser) {
        // If no user was updated, return a 404 status with an error message
        return res
          .status(404)
          .json({ error: 'Error updating user, user not found' });
      }
      // If the user was successfully updated, return a 200 status with a success message
      res
        .status(200)
        .json({ status: true, success: 'User Update Successfully' });
    } else {
      // If the user is not authorized to update the account, return a 403 status with an error message
      return res.status(403).json('You can update only your account!');
    }
  } catch (error) {
    console.error('Error updating user info:', error);
    return res
      .status(500)
      .json({ error: 'Error updating user info', details: error });
  }
};

exports.updateUserInterests = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;
    const givenUserId = req.body._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    // Fetch the user
    const user = await User.findById(givenUserId);

    if (givenUserId === tokenUserId || isAdmin) {
      try {
        const uniqueInterests = [
          ...new Set(
            req.body.interests.map((interest) => interest.toLowerCase())
          ),
        ];

        const user = await User.findByIdAndUpdate(
          givenUserId,
          {
            $set: { interests: uniqueInterests },
          },
          { new: true }
        );

        if (!user) {
          return res
            .status(404)
            .json({ error: 'Error updating user, user not found' });
        }

        res.status(200).json({
          status: true,
          success: 'User interests updated successfully',
        });
      } catch (err) {
        console.error('Error updating user:', err);
        return res
          .status(500)
          .json({ error: 'Error updating user', details: err });
      }
    } else {
      return res.status(403).json('You can update only your account!');
    }
  } catch (error) {
    console.error('Error updating user interests:', error);
    return res
      .status(500)
      .json({ error: 'Error updating user interests', details: error });
  }
};

// This function is used to delete a user's account
exports.deleteAccount = async (req, res) => {
  try {
    const currentUser = await extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;
    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    const givenUserId = req.body._id;
    const givenUser = await User.findById(givenUserId);
    if (!givenUser) {
      return res.status(404).json('User not found');
    }

    // Check if the user is authorized to delete the account
    if (givenUserId === tokenUserId || isAdmin) {
      try {
        
        // Try to delete the user with the given ID
        await User.findByIdAndDelete(givenUserId);
        
        // Try to delete associated calendar with the given ID
        await Calendar.deleteOne({ userId: givenUserId });
        
        const allUsers = await User.find();

        allUsers.forEach(async (user) => {
          let modified = false;

          const bondIndex = user.bonds.indexOf(givenUserId);
          if (bondIndex !== -1) {
            user.bonds.splice(bondIndex, 1);
            modified = true;
          }

          const receivedIndex = user.bondRequestsReceived.indexOf(givenUserId);
          if (receivedIndex !== -1) {
            user.bondRequestsReceived.splice(receivedIndex, 1);
            modified = true;
          }

          const sentIndex = user.bondRequestsSent.indexOf(givenUserId);
          if (sentIndex !== -1) {
            user.bondRequestsSent.splice(sentIndex, 1);
            modified = true;
          }

          if (modified) {
            await user.save();
          }
        });

        res.cookie('jwt', '', { maxAge: 0 });
        // If the user was successfully deleted, return a 200 status with a success message
        res.status(200).json('Account has been deleted');
      } catch (err) {
        // If there's an error deleting the user, return a 500 status with the error
        return res.status(500).json(err);
      }
    } else {
      // If the user is not authorized to delete the account, return a 403 status with an error message
      return res.status(403).json('You can delete only your account!');
    }
  } catch (error) {
    console.error('Error deleting user:', error);
    return res
      .status(500)
      .json({ error: 'Error deleting user', details: error });
  }
};

// This function is used to send a request to recipient
exports.sendBondRequest = async (req, res) => {
  const senderId = (await extractAndDecodeToken(req)).data._id;
  const recipientId = req.body._id;

  if (recipientId !== senderId) {
    try {
      const sender = await User.findById(senderId);
      const recipient = await User.findById(recipientId);

      if (!recipient) {
        return res.status(404).json('Recipient user not found');
      }

      if (!sender) {
        return res.status(404).json('Sender user not found');
      }

      if (
        recipient.bonds.includes(sender.id) &&
        sender.bonds.includes(recipient.id)
      ) {
        return res.status(403).json('Users are already friended');
      }

      await sender.updateOne({ $push: { bondRequestsSent: recipient.id } });
      await recipient.updateOne({ $push: { bondRequestsReceived: sender.id } });

      return res.status(200).json('Friend request sent');
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  } else {
    return res.status(403).json("You can't friend youself");
  }
};

exports.acceptBondRequest = async (req, res) => {
  const recipientId = (await extractAndDecodeToken(req)).data._id;
  const senderId = req.body._id;

  if (senderId !== recipientId) {
    try {
      const recipient = await User.findById(recipientId);
      const sender = await User.findById(senderId);

      if (!recipient || !sender) {
        return res.status(404).json('User not found');
      }

      if (!recipient.bondRequestsReceived.includes(sender.id)) {
        return res.status(400).json('No bond request from this user');
      }

      const result = await UserService.acceptBondRequest(
        recipient.id,
        sender.id
      );

      return res.status(result.status).json(result.message);
    } catch (error) {
      console.log('Error accepting request');
      return res.status(500).json({ error: error.message });
    }
  } else {
    return res.status(403).json('Identical Params and Body ID');
  }
};

exports.declineBondRequest = async (req, res) => {
  const recipientId = (await extractAndDecodeToken(req)).data._id;
  const senderId = req.body._id;

  if (recipientId !== senderId) {
    try {
      const recipient = await User.findById(recipientId);
      const sender = await User.findById(senderId);

      if (!recipient || !sender) {
        return res.status(404).json('User not found');
      }

      if (!recipient.bondRequestsReceived.includes(senderId)) {
        return res
          .status(400)
          .json('Sender ID not found in Recipient Data [bondRequestsReceived]');
      }

      if (!sender.bondRequestsSent.includes(recipientId)) {
        return res
          .status(400)
          .json('Recipient ID not found in Sender Data [bondRequestsSent]');
      }

      await User.findByIdAndUpdate(
        recipientId,
        {
          $pull: { bondRequestsReceived: senderId },
        },
        { new: true }
      );
      await User.findByIdAndUpdate(
        senderId,
        {
          $pull: { bondRequestsSent: recipientId },
        },
        { new: true }
      );

      return res.status(200).json('Bond Request Declined');
    } catch (error) {
      return res.status(500).json({ error: error.message });
    }
  } else {
    return res.status(403).json('Identical Params and Body ID');
  }
};

exports.revokeBondRequest = async (req, res) => {
  try {
    const senderId = (await extractAndDecodeToken(req)).data._id;
    const sender = await User.findById(senderId);
    const recipient = await User.findById(req.body._id);

    if (!recipient || !sender) {
      return res.status(404).json('User not found');
    }

    if (!sender.bondRequestsSent.includes(recipient.id)) {
      return res
        .status(400)
        .json('Recipient ID not found in Sender Data [bondRequestsSent]');
    }

    if (!recipient.bondRequestsReceived.includes(sender.id)) {
      return res
        .status(400)
        .json('Sender ID not found in Recipient Data [bondRequestsReceived]');
    }

    await recipient.updateOne({ $pull: { bondRequestsReceived: sender.id } });
    await sender.updateOne({ $pull: { bondRequestsSent: recipient.id } });

    return res.status(200).json('Bond Request Removed');
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

// This function is used to unfriend another user's account
exports.unBondUser = async (req, res) => {
  const currentUserId = (await extractAndDecodeToken(req)).data._id;
  const targetUserId = req.body._id;

  try {
    if (targetUserId !== currentUserId) {
      const targetUser = await User.findById(targetUserId);
      const currentUser = await User.findById(currentUserId);
      if (
        currentUser.bonds.map((bond) => bond.toString()).includes(targetUserId)
      ) {
        await currentUser.updateOne({
          $pull: { bonds: targetUserId },
          $inc: { numOfBonds: -1 },
        });
        await targetUser.updateOne({
          $pull: { bonds: currentUserId },
          $inc: { numOfBonds: -1 },
        });

        return res.status(200).json('User has been unfriended');
      } else {
        return res.status(403).json('You are not friends with this user');
      }
    } else {
      return res.status(403).json("You can't unfriend yourself");
    }
  } catch (error) {
    return res.status(500).json(error);
  }
};

exports.followOrganization = async (req, res) => {
  const currentUserId = (await extractAndDecodeToken(req)).data._id;
  const currentUser = await User.findById(currentUserId);

  const givenOrganizationId = req.body._id;
  const givenOrganization = await Organization.findById(givenOrganizationId);

  try {
    if (!givenOrganization) {
      return res.status(404).json('Organization not found');
    }

    if (
      currentUser.followedOrganizations.includes(givenOrganization.id) &&
      givenOrganization.followers.includes(currentUser.id)
    ) {
      return res
        .status(403)
        .json('You are already following this organization!');
    }

    await currentUser.updateOne({
      $push: { followedOrganizations: givenOrganization.id },
      $inc: { numOfFollowedOrganizations: +1 },
    });
    await givenOrganization.updateOne({
      $push: { followers: currentUser.id },
      $inc: { numOfFollowers: +1 },
    });

    return res.status(200).json('Organization followed');
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

exports.unfollowOrganization = async (req, res) => {
  const currentUserId = (await extractAndDecodeToken(req)).data._id;
  const currentUser = await User.findById(currentUserId);

  const givenOrganizationId = req.body._id;
  const givenOrganization = await Organization.findById(givenOrganizationId);

  try {
    if (
      currentUser.followedOrganizations // Converts the followedOrganizations array to an array of strings so it can be parsed
        .map((followedOrganization) => followedOrganization.toString())
        .includes(givenOrganizationId)
    ) {
      await currentUser.updateOne({
        $pull: { followedOrganizations: givenOrganizationId },
        $inc: { numOfFollowedOrganizations: -1 },
      });
      await givenOrganization.updateOne({
        $pull: { followers: currentUserId },
        $inc: { numOfFollowers: -1 },
      });

      return res.status(200).json('Organization has been unfollowed');
    } else {
      return res.status(403).json('You are not following this organization!');
    }
  } catch (error) {
    return res.status(500).json(error);
  }
};

exports.interestEvent = async (req, res) => {
  const currentUserId = (await extractAndDecodeToken(req)).data._id;
  const currentUser = await User.findById(currentUserId);

  const givenEventId = req.body._id;
  const givenEvent = await Event.findById(givenEventId);

  try {
    if (!givenEvent) {
      return res.status(404).json('Event not found');
    }

    if (givenEvent.type === 'Private') {
      return res
        .status(403)
        .json('You cannot express interest in a private event!');
    }

    if (
      currentUser.eventInterests.includes(givenEvent.id) &&
      givenEvent.interest.includes(currentUser.id)
    ) {
      return res.status(403).json('You are already interested in this event!');
    }

    await currentUser.updateOne({
      $push: { eventInterests: givenEvent.id },
      $inc: { numOfEventInterests: +1 },
    });
    await givenEvent.updateOne({
      $push: { interest: currentUser.id },
      $inc: { numOfInterest: +1 },
    });

    return res.status(200).json('Event marked as interested');
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};

exports.uninterestEvent = async (req, res) => {
  const currentUserId = (await extractAndDecodeToken(req)).data._id;
  const currentUser = await User.findById(currentUserId);

  const givenEventId = req.body._id;
  const givenEvent = await Event.findById(givenEventId);

  try {
    if (!givenEvent) {
      return res.status(404).json('Event not found');
    }

    if (givenEvent.type === 'Private') {
      return res
        .status(403)
        .json('You cannot retract interest from a private event!');
    }

    if (
      currentUser.eventInterests // Converts the eventInterests array to an array of strings so it can be parsed
        .map((eventInterest) => eventInterest.toString())
        .includes(givenEventId)
    ) {
      await currentUser.updateOne({
        $pull: { eventInterests: givenEventId },
        $inc: { numOfEventInterests: -1 },
      });
      await givenEvent.updateOne({
        $pull: { interest: currentUserId },
        $inc: { numOfInterest: -1 },
      });

      return res.status(200).json('Interest from event has been retracted');
    } else {
      return res.status(403).json('You are not interested in this event!');
    }
  } catch (error) {
    return res.status(500).json(error);
  }
};

exports.makeAdmin = async (req, res) => {
  const { _id } = req.body;
  // Only allow this API to be called by admins
  if (req.user.isAdmin) {
    UserModel.findByIdAndUpdate(_id, { isAdmin: true });
  }
};

exports.logout = async (req, res) => {
  try {
    if (req.headers && req.headers.authorization) {
      const token = req.headers.authorization.split(' ')[1];

      if (!token) {
        return res
          .status(401)
          .json({ status: false, message: 'Authorization fail!' });
      }

      // Verify the token and get the user's ID
      const decoded = await decoder.decodeToken(token);

      if (!decoded) {
        return res
          .status(401)
          .json({ status: false, message: 'Invalid token!' });
      }

      // Find the user in the database
      const user = await User.findOne({
        _id: decoded.data._id,
        tokens: { $elemMatch: { token: token } },
      });

      if (!user) {
        return res
          .status(400)
          .json({ status: false, message: 'Tokens do not match!' });
      }

      // Remove the token from the user's tokens in the database
      await User.updateOne({ _id: user._id }, { $pull: { tokens: { token } } });

      res.json({ status: true, message: 'Log out successfully!' });
    }
  } catch (error) {
    console.log(error);
    res.status(500).json({ status: false, message: 'Logout failed!' });
  }
};
