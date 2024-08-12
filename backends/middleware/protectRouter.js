const jwt = require('jsonwebtoken');
const User = require('../model/user.model');
const rateLimiter = require('../middleware/rateLimiter');

exports.protectRoute = [rateLimiter, async (req, res, next) => {
    try {
        // Extract the token from the Authorization header
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({ error: "Unauthorized - No Token Provided" });
        }

        const token = authHeader.split(' ')[1];

        const decoded = jwt.verify(token, process.env.JWT_KEY);
        
        if (!decoded) {
            return res.status(401).json({ error: "Unauthorized - Invalid Token" });
        }

                const user = await User.findOne({ _id: decoded.data._id, tokens: { $elemMatch: { token: token } } }).select("-password");

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        req.user = user;

        next();
    } catch (error) {
        console.log("Error in protectRoute middleware: ", error.message);
        res.status(500).json({ error: "Internal server error" });
    }
}];