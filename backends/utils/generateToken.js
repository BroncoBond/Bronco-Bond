const jwt = require(`jsonwebtoken`);

class generateToken {
    static async generateToken(data, res, expiresIn = "7d") {
        try {
            const token = jwt.sign({ data }, process.env.JWT_KEY, {
                expiresIn,
            });

            // const dayInMilliseconds = 24 * 60 * 60 * 1000;
            // const maxAge = parseInt(expiresIn) * dayInMilliseconds;

            // res.cookie("jwt", token, {
            //     maxAge, // MS
            //     httpOnly: true, // prevent XSS attacks cross-site scripting attacks
            //     sameSite: "strict", // CSRF attacks cross-site request forgery attacks
            //     secure: process.env.NODE_ENV !== "development",
            // });

            return token;
        } catch (error) {
            console.error('Error generating token:', error.message);
        }
    };
}

module.exports = generateToken;