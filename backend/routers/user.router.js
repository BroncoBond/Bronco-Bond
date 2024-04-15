const router = require('express').Router();
const userController = require("../controller/user.controller");
const auth = require('../middleware/auth');
const protectRouter = require("../middleware/protectRouter");

//register User
router.post('/register', userController.register);

//Login User
router.post('/login', userController.login);

//Search User by Username
router.get('/search', protectRouter.protectRoute, userController.searchUserByUsername);

//Get all User Bonds
router.get('/friendList', protectRouter.protectRoute, userController.getBondList);

//Update User Info
router.put("/updateUserInfo", protectRouter.protectRoute, userController.updateUserInfo);

//Update User Interests
router.put("/updateUserInterest", protectRouter.protectRoute, userController.updateUserInterets);

//Get all User ID
router.get('/ids', userController.getAllUserIds); //Remove during production

//Get all User Data
router.get("/data",userController.getAllUserData); //Remove during production

//Get User by Id
router.get("/", protectRouter.protectRoute, userController.getById);

//Delete User
router.delete("/",protectRouter.protectRoute, userController.deleteAccount);

//Send Bond Request to User
router.put("/sendBondRequest", protectRouter.protectRoute, userController.sendBondRequest);

//Accept Bond Request from User
router.put("/acceptBondRequest", protectRouter.protectRoute, userController.acceptBondRequest);

//Decline Bond Request from User
router.put("/declineBondRequest", protectRouter.protectRoute, userController.declineBondRequest);

//Decline Bond Request from User
router.put("/revokeBondRequest", protectRouter.protectRoute, userController.revokeBondRequest);

//Unfriend User
router.delete("/unBond", protectRouter.protectRoute, userController.unBondUser);

//Logout User
router.post("/logout", protectRouter.protectRoute, userController.logout);

module.exports = router;
