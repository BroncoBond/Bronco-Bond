const router = require('express').Router();
const professorController = require('../controller/professor.controller');
const protectRouter = require('../middleware/protectRouter');

router.post('/create', protectRouter.protectRoute, professorController.createProfessor);

// DEVELOPMENT BUILD ONLY
if (process.env.NODE_ENV === 'development') {
  router.get('/ids', professorController.getAllProfessorIds);
  router.get('/data', professorController.getAllProfessorData);
};

router.delete('/delete', protectRouter.protectRoute, professorController.deleteProfessor);

module.exports = router;