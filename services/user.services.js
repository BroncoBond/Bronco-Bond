const User = require('../model/user.model')
const jwt = require(`jsonwebtoken`);

class UserService{
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


    static async checkuser(email){
        try {
            console.log("Checking User: " + email);
            return await User.findOne({email});
        } catch (error) {
            throw error;
        }
    }

    static async acceptBondRequest(recipientID, senderID) {
        try {
            if (recipientID === senderID) {
                return { status: 400, message: "A user cannot send a bond request to themselves" };
            }

            let recipient = await User.findById(recipientID);
            let sender = await User.findById(senderID);

            if (!recipient.bonds.includes(senderID) && !sender.bonds.includes(recipientID)) {

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

                return { status: 200, message: "Bond request accepted" };
            } else {
                return { status: 403, message: "You are already friended with this user" };
            }
        } catch (error) {
            console.log(error);
            return { status: 500, message: error };
        }
    }

/*     static async searchUserByUsername(username, secretKey, jwt_expre) {
    try {
        const user = await User.findOne({ username });

        if (!user) {
            throw new Error('User not found');
        }

        const tokenData = {
            _id: user._id,
            email: user.email,
            username: user.username
        };

        const token = jwt.sign(tokenData, secretKey, { expiresIn: jwt_expre });

        return { user, token };
    } catch (error) {
        throw error;
    }
} */

    static async generateToken(data,secretKey, jwt_expre) {
        try {
            return jwt.sign(data, secretKey, {expiresIn:jwt_expre});
        } catch (error) {
            throw error;
        }
    }

    static async generateToken(data, secretKey) {
        try {
            return jwt.sign(data, secretKey, {expiresIn:'10d'});
        } catch (error) {
            throw error;
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