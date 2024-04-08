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
router.put("/updateUserInfo/:id", userController.updateUserInfo);

//Update User Interests
router.put("/updateUserInterests/:id", userController.updateUserInterets);

//Get all User ID
router.get('/ids', userController.getAllUserIds);

//Get all User Data
router.get("/data",userController.getAllUserData);

//Get User by Id
router.get("/:id", userController.getById);

//Delete User
router.delete("/:id", userController.deleteAccount);

//Send Bond Request to User
router.put("/sendBondRequest/:id", userController.sendBondRequest);

//Accept Bond Request from User
router.put("/acceptBondRequest/:id", userController.acceptBondRequest);

//Decline Bond Request from User
router.put("/declineBondRequest/:id", userController.declineBondRequest);

//Decline Bond Request from User
router.put("/revokeBondRequest/:id", userController.revokeBondRequest);

//unfriend User
router.delete("/unBond/:id", userController.unBondUser);

//Logout User
router.post("/logout", auth.isAuth, userController.logout);

module.exports = router;
