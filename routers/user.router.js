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

//Get all User ID
router.get('/ids', userController.getAllUserIds);

//Get all User Data
router.get("/data",userController.getAllUserData);

//Get User by Id
router.get("/:id", userController.getById);

//Delete User
router.delete("/:id", userController.deleteAccount);

//friend User
router.put("/bond/:id", userController.bondUser);

//unfriend User
router.delete("/unBond/:id", userController.unfriendUser);

module.exports = router;
