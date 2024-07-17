const router = require('express').Router();
const messageController = require("../controller/message.controller");
const protectRouter = require("../middleware/protectRouter");

router.post("/createEvent",protectRouter.protectRoute, );

module.exports = router;