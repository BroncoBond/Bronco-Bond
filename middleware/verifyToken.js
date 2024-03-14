const User = require("../model/user.model");
const jwt = require("jsonwebtoken");

const verifyToken = (req, res, next) => {
    const authHeader = req.headers.token;

    if (authHeader) {
        const token = authHeader.split(" ")[1];

        jwt.verify(token, process.env.JWT_KEY, async (err, user) => {
            if(err) {
                res.status(403).json('Invalid Token');
            }

            req.user = user;

            console.log(user);

            next();
        });
    } else {
        return res.status(401).json('You are not authenticated');
    }
};

const verifyAndAuthorization = (req, res, next) => {
    verifyToken(req, res, () => {
        if (req.user.id === req.params.id) {
            next();
        } else {
            res.status(403).json('You are restricted from performing this operation')
        }
    })
}

module.exports = {verifyToken, verifyAndAuthorization};