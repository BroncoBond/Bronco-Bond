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
      const { email, name, degree, college, department, classes } = req.body;
      if (!/@cpp\.edu\s*$/.test(email)) {
        res.status(400).json({ status: false, error: 'Invalid Cpp Email' });
      }
      const createProfessor = new Professor({
        email,
        name,
        degree,
        college,
        department,
        classes,
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
};

exports.searchProfessor = async (req, res) => {
  const { email, name, degree, college, department, classes } = req.body;

  if (!(email || name || degree || college || department || classes)) {
    return res
      .status(400)
      .json({ error: 'You must provide at least one search parameter.' });
  }

  if (email && !/@cpp\.edu\s*$/.test(email)) {
    res.status(400).json({ error: 'Invalid Cpp Email' });
  }

  try {
    const query = {};

    if (email) {
      const regex = new RegExp(email, 'i');
      query.email = { $regex: regex };
    }

    if (name) {
      const regex = new RegExp(name, 'i');
      query.name = { $regex: regex };
    }

    if (degree) {
      const regex = new RegExp(degree, 'i');
      query.degree = { $regex: regex };
    }

    if (college) {
      const regex = new RegExp(college, 'i');
      query.college = { $regex: regex };
    }

    if (department) {
      const regex = new RegExp(department, 'i');
      query.department = { $regex: regex };
    }

    if (classes) {
      query.classes = { $in: classes };
    }

    const professors = await Professor.find(query);

    if (professors.length > 0) {
      return res.status(200).json(professors);
    }

    return res.status(404).json({ error: 'No professors found' });
  } catch (error) {
    return res
      .status(500)
      .json({ error: 'An error occurred while searching for professors.' });
  }
}

// (REQUIRES ADMIN)
exports.addClasses = async (req, res) => {
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    if (isAdmin) {
      const givenProfessorId = req.body._id;
      if (!givenProfessorId) {
        return res.status(400).json({ error: 'Professor ID not provided' });
      }

      const { classes } = req.body;
      if (!classes) {
        return res.status(400).json({ error: 'No classes provided' });
      }

      try {
        // If at least one of the provided classes already exists, then an error will be returned and no classes will be added.
        const professor = await Professor.findById(givenProfessorId);
        if (professor.classes.some(c => classes.includes(c))) {
          const matchingClasses = professor.classes.filter(c => classes.includes(c));
          return res.status(400).json({
            error: 'The professor already has the following classes:',
            matchingClasses
          });
        };

        const updatedProfessor = await Professor.findByIdAndUpdate(
          givenProfessorId,
          {
            $addToSet: {
              classes
            },
          },
          { new: true }
        );

        if (!updatedProfessor) {
          return res.status(404).json({
            error: 'No professor ID provided.',
          });
        }

        return res.status(200).json({ 
          message: 'Classes added!', 
          updatedClasses: updatedProfessor.classes
        });
      } catch (error) {
        return res.status(404).json({
          error: 'Error updating professor, professor not found',
        });
      }
    } else {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to add classes to a professor!'
        );
    }
  } catch (error) {
    console.error('Error editing professor\'s classes:', error);
    return res
      .status(500)
      .json({ error: 'Error editing professor\'s classes', details: error });
  }
};

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
}

exports.getById = async (req, res) => {
  const givenProfessorId = req.body._id;
  let professor;
  
  if (!givenProfessorId) {
    return res.status(400).json({ error: 'Professor ID not provided' });
  }

  try {
    professor = await Professor.findById(givenProfessorId).select();

    if (!professor) {
      return res.status(404).json({ error: 'Professor not found' });
    }
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
  return res.status(200).json({ professor });
}

// (REQUIRES ADMIN)
exports.deleteClasses = async (req, res) => {
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    if (isAdmin) {
      const givenProfessorId = req.body._id;
      if (!givenProfessorId) {
        return res.status(400).json({ error: 'Professor ID not provided' });
      }

      const { classes } = req.body;
      if (!classes) {
        return res.status(400).json({ error: 'No classes provided' });
      }

      try {
        // If at least one of the provided classes does not exist, then an error will be returned and no classes will be deleted.
        const professor = await Professor.findById(givenProfessorId);
        const missingClasses = Array.isArray(classes) // The input accepts both a single class or an array of classes.
          ? classes.filter((c) => !professor.classes.includes(c))
          : professor.classes.includes(classes)
        if (missingClasses.length > 0) {
          return res.status(400).json({
            error: 'The professor does not have the following classes:',
            missingClasses,
          });
        }

        const updatedProfessor = await Professor.findByIdAndUpdate(
          givenProfessorId,
          {
            $pullAll: {
              classes: Array.isArray(classes) ? classes : [classes],
            },
          },
          { new: true }
        );

        if (!updatedProfessor) {
          return res.status(404).json({
            error: 'No professor ID provided.',
          });
        }

        return res.status(200).json({
          message: 'Classes deleted!',
          updatedClasses: updatedProfessor.classes,
        });
      } catch (error) {
        console.log(error);
        return res
          .status(404)
          .json({ error: "Error editing professor's classes" });
      }
    } else {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to delete classes from a professor!'
        );
    }
  } catch (error) {
    console.log(error);
    return res
      .status(500)
      .json({ error: "Error editing professor's classes", details: error });
  }
};

// (REQUIRES ADMIN)
exports.deleteProfessor = async (req, res) => {
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    const givenProfessorId = req.body._id;

    if (isAdmin) {
      if (!givenProfessorId) {
        return res.status(400).json({ error: 'Professor ID not provided' });
      }

      const professor = await Professor.findById(givenProfessorId);

      if (!professor) {
        return res.status(404).json({ error: 'Professor not found' });
      }

      try {
        await Professor.findByIdAndDelete(givenProfessorId);
        res.status(200).json('Professor has been deleted');
      } catch (error) {
        return res.status(500).json(error);
      }
    } else {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to delete an professor!'
        );
    }
  } catch (error) {
    console.error('Error deleting professor:', error);
    return res
      .status(500)
      .json({ error: 'Error deleting professor', details: error });
  }
};
