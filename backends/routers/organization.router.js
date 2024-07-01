const router = require('express').Router();
const organizationController = require('../controller/organization.controller');
const protectRouter = require('../middleware/protectRouter');

// Create an organization
router.post(
  '/createOrganization',
  protectRouter.protectRoute,
  organizationController.create
);
