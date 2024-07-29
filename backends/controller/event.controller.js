const Event = require('../model/event.model');

// Used for functions that require administrative permissions
const User = require('../model/user.model');
const userController = require('../controller/user.controller');

// Requires admin
exports.createEvent = async (req, res) => {
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    if (isAdmin) {
      const { title, type, description, startDateTime, endDateTime, location } = req.body;
      const eventCreator = tokenUser;
      const newEvent = new Event({
        title,
        type,
        description,
        eventCreator,
        startDateTime,
        endDateTime,
        location,
      });

      try {
        if (startDateTime > endDateTime) {
          return res.status(400).json({
            message:
              'The start date and time must be before the end date and time!',
          });
        } else if (startDateTime === endDateTime) {
            return res.status(400).json({
                message:
                'The start date and time cannot be the same!',
            });
        }

        await newEvent.save();
         res.status(201).json({
            status: true,
            newEvent,
        });
      } catch (error) {
        if (error.name === 'ValidationError') {
          // Error if name and/or type are not provided
          console.log('Error during event creation: ' + error.message);
          return res.status(400).json({ message: error.message });
        }
        console.log('Error during event creation: ' + error.message);
        return res.status(500).json({ message: error.message });
      }
    } else {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to create an event!'
        );
    }
  } catch (error) {
    console.error('Error creating event:', error);
    return res
      .status(500)
      .json({ error: 'Error creating event', details: error });
  }
};

// Requires admin
exports.deleteEvent = async (req, res) => {
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    const tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    const givenEventId = req.body._id;

    if (isAdmin) {
      if (!givenEventId) {
        return res.status(400).json({ error: 'Event ID not provided' });
      }

      const event = await Event.findById(givenEventId);

      if (!event) {
        return res.status(404).json({ error: 'Event not found' });
      }

      try {
        await Event.findByIdAndDelete(givenEventId);

        return res.status(200).json('Event has been deleted');
      } catch (error) {
        return res.status(500).json(error);
      }
    } else {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to delete an event!'
        );
    }
  } catch (error) {
    console.error('Error deleting event:', error);
    return res
      .status(500)
      .json({ error: 'Error deleting event', details: error });
  }
};