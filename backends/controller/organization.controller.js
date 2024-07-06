const Organization = require('../model/organization.model');

// Used for functions that require administrative permissions
const User = require('../model/user.model');
const userController = require('../controller/user.controller');

// (REQUIRES ADMIN)
exports.createOrganization = async (req, res) => {
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    if (isAdmin) {
      const { name, logo, description, type } = req.body;
      const createOrganization = new Organization({
        name,
        logo,
        description,
        type,
      });

      try {
        console.log('Received organization creation data');
        const newOrganization = await createOrganization.save();
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
    } else {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to create an organization!'
        );
    }
  } catch (error) {
    console.error('Error creating organization:', error);
    return res
      .status(500)
      .json({ error: 'Error creating organization', details: error });
  }
};

// (REQUIRES ADMIN)
exports.updateOrganizationInformation = async (req, res) => {
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    if (isAdmin) {
      const givenOrganizationId = req.body._id;

      const { name, description } = req.body;
      console.log("Updating organization's information");

      try {
        const updatedOrganization = await Organization.findByIdAndUpdate(
          givenOrganizationId,
          {
            $set: {
              name,
              description,
            },
          },
          { new: true } // Returns the updated organization
        );
        if (!updatedOrganization) {
          return res.status(404).json({
            error: 'No organization ID provided.',
          });
        }
        return res.status(200).json(updatedOrganization);
      } catch (error) {
        return res.status(404).json({
          error: 'Error updating organization, organization not found',
        });
      }
    } else {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to edit an organization!'
        );
    }
  } catch (error) {
    console.error('Error editing organization:', error);
    return res
      .status(500)
      .json({ error: 'Error editing organization', details: error });
  }
};

exports.getAllFollowers = async (req, res) => {
  try {
    const currentOrganizationId = req.body._id;
    const currentOrganizationFollowers = await Organization.findById(
      currentOrganizationId
    ).select('followers');
    if (!currentOrganizationFollowers) {
      return res.status(404).json({
        error: 'No organization ID provided.',
      });
    }
    return res
      .status(200)
      .json({ Followers: currentOrganizationFollowers.followers });
  } catch (error) {
    console.error(error);
    return res
      .status(500)
      .json({ error: 'An error occured while fetching the follower list ' });
  }
};

// (COMMENT OUT DURING PROD)
exports.getAllOrganizationIds = async (req, res) => {
  try {
    const organizations = await Organization.find({}, '_id');
    const _id = organizations.map((organization) => organization._id);
    return res.status(200).json(_id);
  } catch (error) {
    console.error('Error fetching Organization IDs:', error);
    return res.status(500).json({ message: error.message });
  }
};

// (COMMENT OUT DURING PROD)
exports.getAllOrganizationData = async (req, res) => {
  try {
    const organizations = await Organization.find({}).select();
    return res.status(200).json(organizations);
  } catch (error) {
    console.error('Error fetching Organization IDs:', error);
    return res.status(500).json({ message: error.message });
  }
};

exports.getById = async (req, res) => {
  const bodyId = req.body._id;
  let organization;
  try {
    organization = await Organization.findById(bodyId).select();
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
  return res.status(200).json({ organization });
};

// (REQUIRES ADMIN)
exports.deleteOrganization = async (req, res) => {
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    const givenOrganizationId = req.body._id;

    if (isAdmin) {
      try {
        await Organization.findByIdAndDelete(givenOrganizationId);

        res.status(200).json('Organization has been deleted');
      } catch (error) {
        return res.status(500).json(error);
      }
    } else {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to delete an organization!'
        );
    }
  } catch (error) {
    console.error('Error deleting organization:', error);
    return res
      .status(500)
      .json({ error: 'Error deleting organization', details: error });
  }
};
