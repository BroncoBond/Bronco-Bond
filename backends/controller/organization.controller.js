const Organization = require('../model/organization.model');
const protectRouter = require('../middleware/protectRouter');

// Function to create an organization
exports.create = async (req, res) => {
  const { name, logo, description } = req.body;
  const createOrganization = new Organization({ name, logo, description });
  try {
    console.log('Received organization creation data');
    const newOrganization = createOrganization.save(); // Saves organization to MongoDB
    console.log('Organization created: ', newOrganization);
  } catch (error) {
    console.log('Error during organization creation: ' + error.message);
  }
};

// (COMMENT OUT DURING PROD) Function to get all Organization IDs
exports.getAllOrganizationIds = async (req, res) => {
  try {
    const organizations = await Organization.find({}, '_id'); // Fetch only the _id field for all Organizations
    const _id = organizations.map((organization) => organization._id); // Extract the _id from each Organization
    return res.status(200).json(_id); // Return the array of Organization IDs
  } catch (error) {
    console.error('Error fetching Organization IDs:', error);
    return res.status(500).json({ message: error.message });
  }
};

// (COMMENT OUT DURING PROD) Function to get all Organization data
exports.getAllOrganizationData = async (req, res) => {
  try {
    const organizations = await Organization.find({}).select(); // Fetch the data of all Organizations
    return res.status(200).json(organizations); // Return the array of Organization data
  } catch (error) {
    console.error('Error fetching Organization IDs:', error);
    return res.status(500).json({ message: error.message });
  }
};

// Function to get Organization by ID
exports.getById = async (req, res) => {
  const bodyId = req.body._id;
  let organization;
  try {
    organization = await Organization.findById(bodyId).select(); // Selects the organization with the matching ID
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
  return res.status(200).json({ organization });
};
