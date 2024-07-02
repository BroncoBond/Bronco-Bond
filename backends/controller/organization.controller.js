const Organization = require('../model/organization.model');

// Function to create an organization
exports.createOrganization = async (req, res) => {
  const { name, logo, description, type } = req.body;
  const createOrganization = new Organization({
    name,
    logo,
    description,
    type,
  });
  try {
    console.log('Received organization creation data');
    const newOrganization = await createOrganization.save(); // Saves organization to MongoDB
    console.log('Organization created: ', newOrganization);
  } catch (error) {
    if (error.name === 'ValidationError') {
      // Error if name and/or type are not provided
      console.log('Error during organization creation: ' + error.message);
      return res.status(400).json({ message: error.message });
    }
    console.log('Error during organization creation: ' + error.message);
    return res.status(500).json({ message: error.message });
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

// // Function to delete Organization
// exports.deleteOrganization = async (req, res) => {
//   try {
//     // Grabs current user's details and their admin status
//     const currentUser = await extractAndDecodeToken(req);
//     const tokenUserId = currentUser.data._id;

//     const tokenUser = await User.findById(tokenUserId).select(
//       'isAdmin'
//     );
//     const isAdmin = tokenUser.isAdmin;

//     // Grabs the ID of the to-be-deleted organization
//     const givenOrganizationId = req.body._id;

//     // Check if the user is authorized to delete the organization
//     if (isAdmin) {
//       try {
//         // Try to delete the Organization with the given ID
//         await Organization.findByIdAndDelete(givenOrganizationId);

//         // If the organization was successfully deleted, return a 200 status with a success message
//         res.status(200).json('Organization has been deleted');
//       } catch (error) {
//         // If there's an error deleting the organization, return a 500 status with the error
//         return res.status(500).json(error);
//       }
//     } else {
//       // If the user is not authorized to delete the organization, return a 403 status with an error message
//       return res
//         .status(403)
//         .json(
//           'Administrative priviledges are required to delete an organization!'
//         );
//     }
//   } catch (error) {
//     console.error('Error deleting organization:', error);
//     return res
//       .status(500)
//       .json({ error: 'Error deleting organization', details: error });
//   }
// };
