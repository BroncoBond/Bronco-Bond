const UserService = require("../services/user.services");
const generateToken = require("../utils/generateToken");
const bcrypt = require("bcrypt");
const User = require("../model/user.model");
const jwt = require('jsonwebtoken');
const mongoose = require('mongoose');
require('dotenv').config();


exports.register = async (req, res, next) => {
    try {
        const { email, username, password } = req.body;
        console.log('Received registration data:', email, username, password);

        const newUser = await UserService.registerUser(email, username, password);
        console.log('User created:', newUser);

        let token;

        try {
            token = await generateToken.generateTokenAndSetCookie(newUser._id,res, '7d');
            console.log("Token generated and cookie set:" + token);
        } catch (err) {
            console.log("Error generating token:", err);
            // If generating the token fails, delete the user
            await newUser.findByIdAndDelete(newUser._id);
            throw err;
        }

        // Log the success response
        console.log("User registered successfully:", newUser);

        res.json({ status: true, success: "User Registered Successfully" , _id: newUser._id, token: token});
    } catch (error) {
        console.log("Error occurred:", error);

        // Log specific errors
        if (error.message === "Email already exists" || error.message === "Username already exists") {
            console.error("Registration error:", error.message);
            return res.status(400).json({ status: false, error: error.message });
        }

        // Log any other errors
        console.error("Error during registration:", error);

        // Send a generic error response
        res.status(500).json({ status: false, error: "Internal Server Error" });
    } 
};



// This function is used to log in a user
exports.login = async(req,res,next)=>{
    try {
        // Extract the email and password from the request body
        const {email,password} = req.body;
        const {staySignedIn} = req.body;
        console.log(staySignedIn);

        // Try to find a user with the given email
        const user = await UserService.checkuser(email);

        // If no user is found, throw an error
        if (!user || !user._id) {
            throw new Error('User does not exist!');
        } else {
            console.log("User found!");
        }

        // Check if the provided password matches the user's password
        console.log("User Password: " + user.password);
        const isMatch = await user.comparePassword(password);
        console.log("isMatch: " + isMatch);
        // If the passwords don't match, throw an error
        if (isMatch === false) {
            throw new Error('Password Invalid');
        }

        // If the passwords match, create a token for the user
        let tokenData = {_id:user._id};

        let token;
        // Generate the token
        if (!staySignedIn)
        {
            token = await UserService.generateToken(tokenData, process.env.JWT_KEY, '10m')
        } else {
            token = await UserService.generateToken(tokenData, process.env.JWT_KEY)
        }
        // Replace the user's existing tokens with new token
        console.log("token: " + token);
        await User.findByIdAndUpdate(user._id, {tokens: [{ token, signedAt: Date.now().toString() }]});

        // If the token was successfully generated, return a 200 status with the token
        res.status(200).json({status:true, token:token})

    } catch (error) {
        // If there's an error during login, log the error and pass it to the next middleware
        console.error('Error during login: ', error);
        next(error);
    }
}

// This function is used to search for a user by their username
exports.searchUserByUsername = async (req, res) => {
    // Extract the username from the request query
    const { username } = req.query;
    
    // Check if a username was provided
    if (!username) {
        return res.status(400).json({ error: 'You must provide a username to search.' });
    }

    try {
        // Create a case-insensitive regular expression to search for usernames that contain the given input
        const regex = new RegExp(username, 'i');

        // Try to find users whose username matches the regular expression
        const users = await User.find({ username: { $regex: regex } }).select('-password -email');

        // If users are found, return the users data
        if (users.length > 0) {
            return res.status(200).json(users);
        }

        // If no users are found, return a 404 status with an error message
        return res.status(404).json({ error: 'No users found' });
    } catch (err) {
        // If there's an error searching for the users, return a 500 status with the error
        console.error('Error searching for users:', err);
        return res.status(500).json({ error: 'An error occurred while searching for users.' });
    }
};

exports.getById = async (req, res) => {
    const _id = req.params.id; // changed from const { _id } = req.params.id;
    let user;
    try {
        user = await User.findById(_id).select('-email -password'); // changed from findById({_id});
    } catch (error) {
        return res.status(500).json({message: error.message});
    }
    if (!user) {
        return res.status(404).json({message: "No User Found"});
    }
    return res.status(200).json({user});
}

exports.getAllUserIds = async (req, res) => {
    try {
        const users = await User.find({}, '_id'); // fetch only the _id field for all users
        const _id = users.map(user => user._id); // extract the _id from each user
        return res.status(200).json(_id); // return the array of user IDs
    } catch (error) {
        console.error('Error fetching user IDs:', error);
        return res.status(500).json({message: error.message});
    }
}

exports.getAllUserData = async (req, res) => {
    try {
        const users = await User.find({}).select('-password -email -profilePicture'); // fetch the user data for all users
        return res.status(200).json(users); // return the array of user data
    } catch (error) {
        console.error('Error fetching user IDs:', error);
        return res.status(500).json({message: error.message});
    }
}

// This function is used to update a user's information
exports.updateUserInfo = async (req, res) => {
    // Check if the user is authorized to update the account
    if (req.body._id === req.params.id || req.body.isAdmin) {
        // If a new password is provided, hash it before storing it
        if (req.body.password) {
            try {
                const salt = await bcrypt.genSalt(10);
                req.body.password = await bcrypt.hash(req.body.password, salt);
            } catch (err) {
                // If there's an error hashing the password, return a 500 status with a detailed error message
                return res.status(500).json({ error: 'Error hashing password', details: err });
            }
        }
        try {
            // Try to find the user with the given ID
            const user = await User.findById(req.body._id);
            if (!user) {
                // If no user is found, return a 404 status with an error message
                return res.status(404).json({ error: 'User not found' });
            }

            // If a new username is provided in the request body
            if (req.body.username) {
                // Try to find a user with the new username
                const existingUser = await User.findOne({ username: req.body.username });
                if (existingUser) {
                    // If a user with the new username already exists, return a 400 status with an error message
                    return res.status(400).json({ error: 'Username already exists' });
                }
            }
            const { username, password, profilePicture, graduationDate, descriptionMajor, descriptionMinor, descriptionBio, fullName, prefName} = req.body;

            // Log the data that will be used to update the user
            console.log('Updating user with data:', req.body);
            
            // Try to update the user with the given ID and data
            const updatedUser = await User.findByIdAndUpdate(req.params.id, {
                $set: { username, password, profilePicture, graduationDate, descriptionMajor, descriptionMinor, descriptionBio, fullName, prefName},
            }, { new: true }); // Add { new: true } to return the updated user

            if (!updatedUser) {
                // If no user was updated, return a 404 status with an error message
                return res.status(404).json({ error: 'Error updating user, user not found' });
            }
        } catch (err) {
            // If there's an error updating the user, log the error and return a 500 status with a detailed error message
            console.error('Error updating user:', err);
            return res.status(500).json({ error: 'Error updating user', details: err });
        }
        // If the user was successfully updated, return a 200 status with a success message
        res.status(200).json({ status: true, success: 'User Update Successfully'});
    } else {
        // If the user is not authorized to update the account, return a 403 status with an error message
        return res.status(403).json("You can update only your account!");
    }
};

exports.updateUserInterets = async (req, res) => {
    if (req.body._id === req.params.id || req.body.isAdmin) {
        try {
                const uniqueInterests = [...new Set(req.body.interests.map(interest => interest.toLowerCase()))];

                const user = await User.findByIdAndUpdate(req.params.id, {
                    $set: { interests: uniqueInterests }
                }, { new: true });

                if (!user) {
                    return res.status(404).json({ error: 'Error updating user, user not found' });
                }

                res.status(200).json({ status: true, success: 'User interests updated successfully'});
            } catch (err) {
                console.error('Error updating user:', err);
                return res.status(500).json({ error: 'Error updating user', details: err });
        }
    } else {
        return res.status(403).json("You can update only your account!");
    }
}

// This function is used to delete a user's account
exports.deleteAccount = async (req, res) => {
    // Check if the user is authorized to delete the account
    if (req.body._id === req.params.id || req.body.isAdmin) {
        try {
            // Try to delete the user with the given ID
            await User.findByIdAndDelete(req.params.id);
            // If the user was successfully deleted, return a 200 status with a success message
            res.status(200).json("Account has been deleted");
        } catch (err) {
            // If there's an error deleting the user, return a 500 status with the error
            return res.status(500).json(err);
        }
    } else {
        // If the user is not authorized to delete the account, return a 403 status with an error message
        return res.status(403).json("You can delete only your account!");
    }
};

// This function is used to send a request to recipient
exports.sendBondRequest = async (req, res) => {
    if (req.body._id !== req.params.id) {
        try {
            const recipient = await User.findById(req.params.id);
            const sender = await User.findById(req.body._id);

            if (recipient.bonds.includes(sender.id) && sender.bonds.includes(recipient.id)) {
                return res.status(403).json("Users are already friended");
            }

            if (!recipient) {
                return res.status(404).json("Recipient user not found");
            }

            if (!sender) {
                return res.status(404).json("Sender user not found");
            }
            
            await sender.updateOne({ $push: { bondRequestsSent: recipient.id } });
            await recipient.updateOne({ $push: { bondRequestsReceived: sender.id } });

            return res.status(200).json("Friend request sent");
        } catch (error) {
            return res.status(500).json({ error: error.message});
        }
    } else {
        return res.status(403).json("You can't friend youself");
    }
}

exports.acceptBondRequest = async(req, res) => {
    if (req.params.id !== req.body._id) {
        try {
            const recipient = await User.findById(req.params.id);
            const sender = await User.findById(req.body._id);

            if (!recipient || !sender) {
                return res.status(404).json("User not found");
            }

            if (!recipient.bondRequestsReceived.includes(sender.id)) {
                return res.status(400).json("No bond request from this user");
            }

            const result = await UserService.acceptBondRequest(recipient.id, sender.id);
            
            return res.status(result.status).json(result.message);
        } catch (error) {
            console.log(error);
            return res.status(500).json({ error: error.message });
        }
    } else {
        return res.status(403).json("Identical Params and Body ID");
    }
}

exports.declineBondRequest = async(req, res) => {
    if (req.params.id !== req.body._id) {
        try {
            const recipient = await User.findById(req.params.id);
            const sender = await User.findById(req.body._id);

            if (!recipient || !sender) {
                return res.status(404).json("User not found");
            }

            if (!recipient.bondRequestsReceived.includes(req.body._id)) {
                return res.status(400).json("Sender ID not found in Recipient Data [bondRequestsReceived]");
            }

            if (!sender.bondRequestsSent.includes(req.params.id)) {
                return res.status(400).json("Recipient ID not found in Sender Data [bondRequestsSent]");
            }

            await User.findByIdAndUpdate(req.params.id, {
                $pull: { bondRequestsReceived: req.body._id}
            }, {new: true});
            await User.findByIdAndUpdate(req.body._id, {
                $pull: { bondRequestsSent: req.params.id}
            }, {new: true});

            return res.status(200).json("Bond Request Declined");
        } catch (error) {
            return res.status(500).json({ error: error.message });
        }
    } else {
        return res.status(403).json("Identical Params and Body ID");
    }
}

exports.revokeBondRequest = async (req, res) => {
    try {
        const sender = await User.findById(req.params.id);
        const recipient = await User.findById(req.body._id);

        if (!recipient || !sender) {
            return res.status(404).json("User not found");
        }

        if (!sender.bondRequestsSent.includes(recipient.id)) {
            return res.status(400).json("Recipient ID not found in Sender Data [bondRequestsSent]");
        }

        if (!recipient.bondRequestsReceived.includes(sender.id)) {
            return res.status(400).json("Sender ID not found in Recipient Data [bondRequestsReceived]");
        }

        await recipient.updateOne({ $pull: { bondRequestsReceived: sender.id}});
        await sender.updateOne({ $pull: { bondRequestsSent: recipient.id}});

        return res.status(200).json("Bond Request Removed");
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
}

// This function is used to unfriend another user's account
exports.unBondUser = async (req, res) => {
    try {
        if (req.body._id !== req.params.id) {
            const user = await User.findById(req.params.id);
            const currentUser = await User.findById(req.body._id);
            console.log(typeof req.body._id); // Log the type of req.body._id
            console.log(typeof req.params.id); // Log the type of req.params.id
            console.log(user.bonds.map(bond => typeof bond)); // Log the types of the elements of user.bonds
            if (user.bonds.map(bond => bond.toString()).includes(req.body._id)) {
                await user.updateOne({ $pull: { bonds: req.body._id }, $inc: { numOfBonds: -1 } });
                await currentUser.updateOne({ $pull: { bonds: req.params.id }, $inc: { numOfBonds: -1 } });
                console.log('User bonds after:', user.bonds);
                console.log('Current user bonds after:', currentUser.bonds);
                return res.status(200).json("User has been unfriended");
            } else {
                return res.status(403).json("You are not friends with this user");
            }
        } else {
            return res.status(403).json("You can't unfriend yourself");
        }
    } catch (error) {
        return res.status(500).json(error);
    }
}

exports.makeAdmin = async (req, res) => {
    const { _id } = req.body;
    // Only allow this API to be called by admins
    if (req.user.isAdmin) {
        UserModel.findByIdAndUpdate(_id, { isAdmin: true });
    }
};

exports.logout = async (req, res) => {
  if (req.headers && req.headers.authorization) {
    const token = req.headers.authorization.split(' ')[1];
    if (!token) {
      return res
        .status(401)
        .json({ status: false, message: 'Authorization fail!' });
    }

    const tokens = req.user.tokens;

    const newTokens = tokens.filter(t => t.token !== token);

    await User.updateOne({ _id: req.user._id }, { $pull: { tokens: { token } } });
    console.log("Signout Successful");

    res.cookie('jwt', '', { maxAge: 0 });
    console.log('Cookie reset!');

    res.json({ status: true, message: 'Log out successfully!' });
  }
};


