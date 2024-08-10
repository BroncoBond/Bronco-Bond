const router = require('express').Router();
const organizationController = require('../controller/organization.controller');
const protectRouter = require('../middleware/protectRouter');

// Create an organization
router.post(
  '/create',
  protectRouter.protectRoute,
  organizationController.createOrganization
);

// Update Organization's information
router.put(
  '/update',
  protectRouter.protectRoute,
  organizationController.updateOrganization
);

// Get all Organization folllowers
router.get(
  '/followers',
  protectRouter.protectRoute,
  organizationController.getAllFollowers
);

// DEVELOPMENT BUILD ONLY
if (process.env.NODE_ENV === 'development') {
  // Get all Organization IDs
  router.get('/ids', organizationController.getAllOrganizationIds);

  // Get all Organization data
  router.get('/data', organizationController.getAllOrganizationData);
};

// Get Organization by ID
router.post('/', protectRouter.protectRoute, organizationController.getById);

// Delete an organization
router.delete(
  '/delete',
  protectRouter.protectRoute,
  organizationController.deleteOrganization
);

module.exports = router;
