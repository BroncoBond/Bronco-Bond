const Organization = require('../model/organization.model');
const protectRouter = require('../middleware/protectRouter');

// Function to create an organization
exports.create = async (req, res) => {
  const { name, logo, description } = req.body;
  console.log(name, logo, description);
  const createOrganization = new Organization({ name, logo, description });
  try {
    console.log('Received organization creation data');
    const newOrganization = createOrganization.save(); // Saves organization to MongoDB
    console.log('Organization created: ', newOrganization);
  } catch (error) {
    console.log('Error during organization creation: ' + error.message);
  }
};
