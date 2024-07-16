const router = require('express').Router();
const professorController = require('../controller/professor.controller');
const protectRouter = require('../middleware/protectRouter');

router.post('/create', protectRouter.protectRoute, professorController.createProfessor);

// DEVELOPMENT BUILD ONLY
if (process.env.NODE_ENV === 'development') {
  // Get all Professor IDs
  router.get('/ids', professorController.getAllProfessorIds);

  // Get all Professor data
  router.get('/data', professorController.getAllProfessorData);
};

module.exports = router;