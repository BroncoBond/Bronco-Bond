const router = require('express').Router();
const eventController = require('../controller/event.controller');
const protectRouter = require('../middleware/protectRouter');

router.post('/create', protectRouter.protectRoute, eventController.createEvent);

router.put('/update', protectRouter.protectRoute, eventController.updateEvent);

router.get('/search', protectRouter.protectRoute, eventController.searchEvent);

router.get("/", protectRouter.protectRoute, eventController.getById);

router.delete('/delete', protectRouter.protectRoute, eventController.deleteEvent);

module.exports = router;