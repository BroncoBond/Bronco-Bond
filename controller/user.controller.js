const UserService = require("../services/user.services");


exports.register = async(req,res,next)=>{
    try {
        const {email,username,password} = req.body;

        const successRes = await UserService.registerUser(email,username,password);

        res.json({status: true, success: "User Registered Successfully"});
    }catch(error){
        throw error
    }
}

exports.login = async(req,res,next)=>{
    try {
        const {email,password} = req.body;
        console.log("------",password);

        const user = await UserService.checkuser(email);
        console.log("----------------------------------------user---------------------------",user);

        if (!user) {
            throw new Error('User does not exist!');
        }

        const isMatch = await user.comparePassword(password);
        
        if (isMatch === false) {
            throw new Error('Password Invalid');
        }

        let tokenData = {_id:user._id,email:user.email};

        const token = await UserService.generateToken(tokenData, "secretKey", '1h')

        res.status(200).json({status:true, token:token})

    } catch (error) {
        throw error
    }
}

exports.searchUserByEmail = async (req, res, next) => {
    try {
        console.log('Search endpoint reached');
        const { email } = req.query;
        console.log('Search email:', email);

        const user = await UserService.searchUserByEmail(email);

        if (!user) {
            return res.status(404).json({ status: false, error: 'User not found' });
        }

        res.status(200).json({ status: true, user });
    } catch (error) {
        console.error('Error in searchUserByEmail:', error);
        res.status(500).json({ status: false, error: "Internal Server Error" });
    }
};

