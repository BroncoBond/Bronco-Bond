const router = require('express').Router();
const eventController = require('../controller/event.controller');
const protectRouter = require('../middleware/protectRouter');

router.post('/create', protectRouter, eventController.createEvent);

module.exports = router;