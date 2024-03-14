const router = require('express').Router();
const auth = require('../middleware/auth');
const { verifyAndAuthorization } = require('../middleware/verifyToken');

// Send Messages
router.post("/",verifyAndAuthorization, messageController.sendMessage)

// Get All Messages
// router.get("/allMessage/:id", messageController.getAllMessages);



module.exports = router;
