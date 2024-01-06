const router = require('express').Router();
const UserController = require("../controller/user.controller");

router.post('/register', UserController.register);
router.post('/login', UserController.login);
router.get('/search', UserController.searchUserByUsernameOrEmail);

module.exports = router;
