const UserModel = require('../model/user.model')
const jwt = require(`jsonwebtoken`);

class UserService{
    static async registerUser(email, username, password) {
        try {
            const createUser = new UserModel({ email, username, password });
            const newUser = await createUser.save();

            // Log the newly created user
            console.log('User registered:', newUser);

            return newUser;
        } catch (error) {
            if (error.name === 'MongoError' && error.code === 11000) {
                // Duplicate key error
                if (error.keyPattern && error.keyPattern.email) {
                    // Duplicate email error
                    throw new Error('Email already exists');
                } else if (error.keyPattern && error.keyPattern.username) {
                    // Duplicate username error
                    throw new Error('Username already exists');
                }
            }
            // For other errors, log and rethrow
            console.error('Error during user registration:', error);
            throw error;
        }
    }


    static async checkuser(email){
        try {
            return await UserModel.findOne({email});
        } catch (error) {
            throw error;
        }
    }

    static async searchUserByEmail(email) {
        try {
            const user = await UserModel.findOne({ email });
            return user;
        } catch (error) {
            throw error;
        }
    }

    static async generateToken(tokenData,secretKey, jwt_expre) {
        try {
            return jwt.sign(tokenData, secretKey, {expiresIn:jwt_expre});
        } catch (error) {
            throw error;
        }
    }
}

module.exports = UserService;