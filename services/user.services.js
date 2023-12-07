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

module.exports = UserService;