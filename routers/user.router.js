const router = require('express').Router();
const UserController = require("../controller/user.controller");

//register User
router.post('/register', UserController.register);

//login User
router.post('/login', UserController.login);

//Search User by Username
router.get('/search', UserController.searchUserByUsername);

//Update User Info
router.put("/:id", UserController.updateUserInfo);

//Delete User
router.delete("/:id", UserController.deleteAccount);

module.exports = router;
