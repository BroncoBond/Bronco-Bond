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
router.get('/search', protectRouter.protectRoute, userController.searchUserByUsername);

//Get all User Bonds
router.get('/friendList', protectRouter.protectRoute, userController.getBondList);

//Get all followed Organizations
router.get('/followedOrganizations', protectRouter.protectRoute, userController.getFollowedOrganizations);

//Get User Calendar
router.get('/calendar', protectRouter.protectRoute, userController.getCalendar);

//Update User Info
router.put("/updateUserInfo", protectRouter.protectRoute, userController.updateUserInfo);

//Update User Interests
router.put("/updateUserInterest", protectRouter.protectRoute, userController.updateUserInterests);

// DEVELOPMENT BUILD ONLY
if (process.env.NODE_ENV === 'development') {
  //Get all User ID
  router.get('/ids', userController.getAllUserIds);

  //Get all User Data
  router.get('/data', userController.getAllUserData); // DEVELOPMENT BUILD ONLY
};

//Get User by Id
router.post("/", protectRouter.protectRoute, userController.getById);

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

//Follow an Organization
router.put("/followOrganization", protectRouter.protectRoute, userController.followOrganization);

//Unfollow an Organization
router.delete("/unfollowOrganization", protectRouter.protectRoute, userController.unfollowOrganization);

//Express interest in a public Event
router.put("/interestEvent", protectRouter.protectRoute, userController.interestEvent);

//Retract interest from a public Event
router.delete("/uninterestEvent", protectRouter.protectRoute, userController.uninterestEvent);

//Logout User
router.post("/logout", protectRouter.protectRoute, userController.logout);

module.exports = router;
