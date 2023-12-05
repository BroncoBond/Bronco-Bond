const UserModel = require('../model/user.model')
const jwt = require(`jsonwebtoken`);

class UserService{
    static async registerUser(email,username,password){
        try{
            const createUser = new UserModel({email,username,password});
            return await createUser.save();
        }catch(err){
            throw err;
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
            return await UserModel.findOne({ email });
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