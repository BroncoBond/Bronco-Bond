const router = require('express').Router();
const professorController = require('../controller/professor.controller');
const protectRouter = require('../middleware/protectRouter');

router.post('/create', protectRouter.protectRoute, professorController.createProfessor);

module.exports = router;