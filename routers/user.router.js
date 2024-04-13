const router = require('express').Router();
const userController = require("../controller/user.controller");
const auth = require('../middleware/auth');
const protectRouter = require("../middleware/protectRouter");

//register User
router.post('/register', userController.register);

//login User
router.post('/login', userController.login);

//Search User by Username
router.get('/search', protectRouter.protectRoute, userController.searchUserByUsername);

//Update User Info
router.put("/updateUserInfo", protectRouter.protectRoute, userController.updateUserInfo);

//Update User Interests
router.put("/updateUserInterest", protectRouter.protectRoute, userController.updateUserInterets);

//Get all User ID
router.get('/ids', userController.getAllUserIds);

//Get all User Data
router.get("/data",userController.getAllUserData);

//Get User by Id
router.get("/:id", protectRouter.protectRoute, userController.getById);

//Delete User
router.delete("/:id",protectRouter.protectRoute, userController.deleteAccount);

//Send Bond Request to User
router.put("/sendBondRequest/:id", protectRouter.protectRoute, userController.sendBondRequest);

//Accept Bond Request from User
router.put("/acceptBondRequest/:id", protectRouter.protectRoute, userController.acceptBondRequest);

//Decline Bond Request from User
router.put("/declineBondRequest/:id", protectRouter.protectRoute, userController.declineBondRequest);

//Decline Bond Request from User
router.put("/revokeBondRequest/:id", protectRouter.protectRoute, userController.revokeBondRequest);

//unfriend User
router.delete("/unBond/:id", protectRouter.protectRoute, userController.unBondUser);

//Logout User
router.post("/logout", protectRouter.protectRoute, userController.logout);

module.exports = router;
