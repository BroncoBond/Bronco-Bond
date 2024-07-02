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
//     const currentUser = await extractAndDecodeToken(req);
//     const tokenUserId = currentUser.data._id;
//     const givenUserId = req.body._id;

//     // Check if the User is authorized to delete the Organization
//     if (givenUserId === tokenUserId || isAdmin) {
//       try {
//         const userId = req.user._id;
//         // Try to delete the Organization with the given ID
//         await Organization.findByIdAndDelete(givenUserId);

//         const allUsers = await User.find();

//         allUsers.forEach(async (user) => {
//           let modified = false;

//           const bondIndex = user.bonds.indexOf(givenUserId);
//           if (bondIndex !== -1) {
//             user.bonds.splice(bondIndex, 1);
//             modified = true;
//           }

//           const receivedIndex = user.bondRequestsReceived.indexOf(givenUserId);
//           if (receivedIndex !== -1) {
//             user.bondRequestsReceived.splice(receivedIndex, 1);
//             modified = true;
//           }

//           const sentIndex = user.bondRequestsSent.indexOf(givenUserId);
//           if (sentIndex !== -1) {
//             user.bondRequestsSent.splice(sentIndex, 1);
//             modified = true;
//           }

//           if (modified) {
//             await user.save();
//           }
//         });

//         res.cookie('jwt', '', { maxAge: 0 });
//         // If the user was successfully deleted, return a 200 status with a success message
//         res.status(200).json('Organization has been deleted');
//       } catch (error) {
//         // If there's an error deleting the user, return a 500 status with the error
//         return res.status(500).json(error);
//       }
//     } else {
//       // If the User is not authorized to delete the Organization, return a 403 status with an error message
//       return res.status(403).json('You can delete only your organizations!');
//     }
//   } catch (error) {
//     console.error('Error deleting organization:', error);
//     return res
//       .status(500)
//       .json({ error: 'Error deleting organization', details: error });
//   }
// };
