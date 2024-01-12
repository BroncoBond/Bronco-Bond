const router = require('express').Router();
const userController = require("../controller/user.controller");

//register User
router.post('/register', userController.register);

//login User
router.post('/login', userController.login);

//Search User by Username
router.get('/search', userController.searchUserByUsername);

//Update User Info
router.put("/userUpdate/:id", userController.updateUserInfo);

//Get User by Id
router.get("/:id", userController.getById);

//Delete User
router.delete("/:id", userController.deleteAccount);

//follow User
router.get("/:id/follow", userController.followUser);

//Get all User ID
router.get('/ids', userController.getAllUserIds);

module.exports = router;
