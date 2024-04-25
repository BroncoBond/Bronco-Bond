const router = require('express').Router();
const messageController = require("../controller/message.controller");
const protectRouter = require("../middleware/protectRouter");

router.post("/sendMessage",protectRouter.protectRoute, messageController.sendMessage);

router.post("/getMessage",protectRouter.protectRoute, messageController.getMessage);

module.exports = router;