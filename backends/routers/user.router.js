const router = require('express').Router();
const userController = require("../controller/user.controller");
const auth = require('../middleware/auth');
const protectRouter = require("../middleware/protectRouter");

//Register User
router.post('/register', userController.register);

//Verify User
router.post('/verify', protectRouter.protectRoute, userController.verifyOTP);

//Resend verification code
router.post('/resendVerification', protectRouter.protectRoute, userController.resendOTP);

//Login User
router.post('/login', userController.login);

//Search User by Username
router.get('/search', protectRouter.protectRouteCheckVerify, userController.searchUserByUsername);

//Get all User Bonds
router.get('/friendList', protectRouter.protectRouteCheckVerify, userController.getBondList);

//Get all followed Organizations
router.get('/followedOrganizations', protectRouter.protectRouteCheckVerify, userController.getFollowedOrganizations);

//Get User Calendar
router.get('/calendar', protectRouter.protectRouteCheckVerify, userController.getCalendar);

//Update User Info
router.put("/updateUserInfo", protectRouter.protectRouteCheckVerify, userController.updateUserInfo);

//Update User Interests
router.put("/updateUserInterest", protectRouter.protectRouteCheckVerify, userController.updateUserInterests);

// DEVELOPMENT BUILD ONLY
if (process.env.NODE_ENV === 'development') {
  //Get all User ID
  router.get('/ids', userController.getAllUserIds);

  //Get all User Data
  router.get('/data', userController.getAllUserData); // DEVELOPMENT BUILD ONLY
};

//Get User by Id
router.post("/", protectRouter.protectRouteCheckVerify, userController.getById);

//Delete User
router.delete("/",protectRouter.protectRouteCheckVerify, userController.deleteAccount);

//Send Bond Request to User
router.put("/sendBondRequest", protectRouter.protectRouteCheckVerify, userController.sendBondRequest);

//Accept Bond Request from User
router.put("/acceptBondRequest", protectRouter.protectRouteCheckVerify, userController.acceptBondRequest);

//Decline Bond Request from User
router.put("/declineBondRequest", protectRouter.protectRouteCheckVerify, userController.declineBondRequest);

//Decline Bond Request from User
router.put("/revokeBondRequest", protectRouter.protectRouteCheckVerify, userController.revokeBondRequest);

//Unfriend User
router.delete("/unBond", protectRouter.protectRouteCheckVerify, userController.unBondUser);

//Follow an Organization
router.put("/followOrganization", protectRouter.protectRouteCheckVerify, userController.followOrganization);

//Unfollow an Organization
router.delete("/unfollowOrganization", protectRouter.protectRouteCheckVerify, userController.unfollowOrganization);

//Express interest in a public Event
router.put("/interestEvent", protectRouter.protectRouteCheckVerify, userController.interestEvent);

//Retract interest from a public Event
router.delete("/uninterestEvent", protectRouter.protectRouteCheckVerify, userController.uninterestEvent);

//Logout User
router.post("/logout", protectRouter.protectRouteCheckVerify, userController.logout);

module.exports = router;
