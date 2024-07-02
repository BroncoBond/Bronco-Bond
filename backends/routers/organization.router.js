const router = require('express').Router();
const organizationController = require('../controller/organization.controller');
const protectRouter = require('../middleware/protectRouter');

// Create an organization
router.post(
  '/createOrganization',
  protectRouter.protectRoute,
  organizationController.create
);

// Get all Organization data (Comment out during prod)
router.get(
  '/data',
  protectRouter.protectRoute,
  organizationController.getAllOrganizationData
);

// Get Organization by ID
router.post('/', protectRouter.protectRoute, organizationController.getById);

module.exports = router;
