const Professor = require('../model/professor.model');

// Used for functions that require administrative permissions
const User = require('../model/user.model');
const userController = require('../controller/user.controller');

// (REQUIRES ADMIN)
exports.createProfessor = async (req, res) => {
    try {
      const currentUser = await userController.extractAndDecodeToken(req);
      const tokenUserId = currentUser.data._id;

      const tokenUser = await User.findById(tokenUserId).select('isAdmin');
      const isAdmin = tokenUser.isAdmin;

      if (isAdmin) {
        const { email, name, degree, college, department } = req.body;
        if (!/@cpp\.edu\s*$/.test(email)) {
          res.status(400).json({ status: false, error: 'Invalid Cpp Email' });
        }
        const createProfessor = new Professor({
          email,
          name,
          degree,
          college,
          department,
        });

        try {
          console.log('Received professor creation data');
          const newProfessor = await createProfessor.save();
          console.log('Professor created: ', newProfessor);
          res.status(201).json({
            status: true,
            success: 'Professor Created Successfully',
          });
        } catch (error) {
          if (error.name === 'ValidationError') {
            // Error if name and/or type are not provided
            console.log('Error during professor creation: ' + error.message);
            return res.status(400).json({ message: error.message });
          }
          console.log('Error during professor creation: ' + error.message);
          return res.status(500).json({ message: error.message });
        }
      } else {
        return res
          .status(403)
          .json(
            'Administrative priviledges are required to create an professor!'
          );
      }
    } catch (error) {
      console.error('Error creating professor:', error);
      return res
        .status(500)
        .json({ error: 'Error creating professor', details: error });
    }
}

// DEVELOPMENT BUILD ONLY
if (process.env.NODE_ENV === 'development') {
  exports.getAllProfessorIds = async (req, res) => {
    try {
      const professors = await Professor.find({}, '_id');
      const _id = professors.map((professor) => professor._id);
      return res.status(200).json(_id);
    } catch (error) {
      console.error('Error fetching Professor IDs:', error);
      return res.status(500).json({ message: error.message });
    }
  };

  exports.getAllProfessorData = async (req, res) => {
    try {
      const professors = await Professor.find({}).select();
      return res.status(200).json(professors);
    } catch (error) {
      console.error('Error fetching Professor Data:', error);
      return res.status(500).json({ message: error.message });
    }
  };
};