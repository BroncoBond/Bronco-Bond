const jwt = require(`jsonwebtoken`);

class generateToken {
    static async generateTokenAndSetCookie(userId, res, expiresIn = "7d") {
        const token = jwt.sign({ userId }, process.env.JWT_SECRET, {
            expiresIn,
        });

        res.cookie("jwt", token, {
            maxAge: 15 * 24 * 60 * 60 * 1000, // MS
            httpOnly: true, // prevent XSS attacks cross-site scripting attacks
            sameSite: "strict", // CSRF attacks cross-site request forgery attacks
            secure: process.env.NODE_ENV !== "development",
        });
        return token;
    };
}

module.exports = generateToken;