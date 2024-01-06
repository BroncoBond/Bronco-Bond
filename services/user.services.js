const UserModel = require('../model/user.model')
const jwt = require(`jsonwebtoken`);

class UserService{
    static async registerUser(email, username, password) {
        const createUser = new UserModel({ email, username, password });
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
            return await UserModel.findOne({email});
        } catch (error) {
            throw error;
        }
    }

    static async searchUserByUsernameOrEmail(identifier, secretKey, jwt_expre) {
    try {
        const user = await UserModel.findOne({ 
            $or: [
                { username: identifier },
                { email: identifier }
            ]
        });

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
}

    static async generateToken(user,secretKey, jwt_expre) {
        try {
            const tokenData = {
                _id: user._id,
                email: user.email,
                username: user.username
            };
            return jwt.sign(tokenData, secretKey, {expiresIn:jwt_expre});
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