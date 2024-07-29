const router = require('express').Router();
const eventController = require('../controller/event.controller');
const protectRouter = require('../middleware/protectRouter');

// Requires admin
router.post('/create', protectRouter.protectRoute, eventController.createEvent);

router.get("/", protectRouter.protectRoute, eventController.getById);

// Requires admin
router.delete('/delete', protectRouter.protectRoute, eventController.deleteEvent);

module.exports = router;