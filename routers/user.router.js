const router = require('express').Router();
const userController = require("../controller/user.controller");
const auth = require('../middleware/auth');

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

//Send Bond Request to User
router.put("/sendBond/:id", userController.requestBondUser);

//Accept Bond Request from User
router.put("/acceptBond/:id", userController.acceptBondRequest);

//Decline Bond Request from User
router.put("/declineBond/:id", userController.declineBondRequest)

//unfriend User
router.delete("/unBond/:id", userController.unfriendUser);

//Logout User
router.post("/logout", auth.isAuth, userController.logout);

module.exports = router;
