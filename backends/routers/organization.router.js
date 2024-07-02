const router = require('express').Router();
const organizationController = require('../controller/organization.controller');
const protectRouter = require('../middleware/protectRouter');

// Create an organization
router.post(
  '/createOrganization',
  protectRouter.protectRoute,
  organizationController.createOrganization
);

// (COMMENT OUT DURING PROD) Get all Organization IDs
router.get(
  '/ids',
  protectRouter.protectRoute,
  organizationController.getAllOrganizationIds
);

// (COMMENT OUT DURING PROD) Get all Organization data
router.get(
  '/data',
  protectRouter.protectRoute,
  organizationController.getAllOrganizationData
);

// Get Organization by ID
router.post('/', protectRouter.protectRoute, organizationController.getById);

// // Delete an organization
// router.deleteOrganization(
//   '/deleteOrganization',
//   protectRouter.protectRoute,
//   organizationController.delete
// );

module.exports = router;
