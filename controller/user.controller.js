const UserService = require("../services/user.services");
const bcrypt = require("bcrypt");
const User = require("../model/user.model");


exports.register = async (req, res, next) => {
    try {
        const { email, username, password } = req.body;

        const successRes = await UserService.registerUser(email, username, password);

        // Log the success response
        console.log('User registered successfully:', successRes);

        res.json({ status: true, success: 'User Registered Successfully' });
    } catch (error) {
        // Log specific errors
        if (error.message === 'Email already exists' || error.message === 'Username already exists') {
            console.error('Registration error:', error.message);
            return res.status(400).json({ status: false, error: error.message });
        }

        // Log any other errors
        console.error('Error during registration:', error);

        // Send a generic error response
        res.status(500).json({ status: false, error: 'Internal Server Error' });
    }
};



// This function is used to log in a user
exports.login = async(req,res,next)=>{
    try {
        // Extract the email and password from the request body
        const {email,password} = req.body;

        // Log the password for debugging purposes (note: this is generally not a good practice for production code due to security reasons)
        console.log("------",password);

        // Try to find a user with the given email
        const user = await UserService.checkuser(email);

        // Log the user for debugging purposes
        console.log("----------------------------------------user---------------------------",user);

        // If no user is found, throw an error
        if (!user) {
            throw new Error('User does not exist!');
        }

        // Check if the provided password matches the user's password
        const isMatch = await user.comparePassword(password);
        
        // If the passwords don't match, throw an error
        if (isMatch === false) {
            throw new Error('Password Invalid');
        }

        // If the passwords match, create a token for the user
        let tokenData = {_id:user._id,email:user.email,username:user.username};

        // Generate the token
        const token = await UserService.generateToken(tokenData, "secretKey", '10m')

        // If the token was successfully generated, return a 200 status with the token
        res.status(200).json({status:true, token:token})

    } catch (error) {
        // If there's an error during login, log the error and pass it to the next middleware
        console.error('Error during login: ', error);
        next(error);
    }
}

// This function is used to search for a user by their username or email
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



// This function is used to update a user's information
exports.updateUserInfo = async (req, res) => {
    // Check if the user is authorized to update the account
    if (req.body.userId === req.params.id || req.body.isAdmin) {
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
            const user = await User.findById(req.params.id);
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

            // Log the data that will be used to update the user
            console.log('Updating user with data:', req.body);
            // Try to update the user with the given ID and data
            const updatedUser = await User.findByIdAndUpdate(req.params.id, {
                $set: req.body,
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
        res.status(200).json("Account has been updated");
    } else {
        // If the user is not authorized to update the account, return a 403 status with an error message
        return res.status(403).json("You can update only your account!");
    }
};

// This function is used to delete a user's account
exports.deleteAccount = async (req, res) => {
    // Check if the user is authorized to delete the account
    if (req.body.userId === req.params.id || req.body.isAdmin) {
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

// This function is used to follow another user's account


