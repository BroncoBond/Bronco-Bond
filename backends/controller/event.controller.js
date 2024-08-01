const Event = require('../model/event.model');

// Used for functions that require administrative permissions
const User = require('../model/user.model');
const userController = require('../controller/user.controller');

exports.createEvent = async (req, res) => {
  // Public events can only be created by admins
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;

    let tokenUser = await User.findById(tokenUserId).select('isAdmin');
    const isAdmin = tokenUser.isAdmin;

    let {
      title,
      type,
      description,
      eventHost,
      startDateTime,
      endDateTime,
      location,
    } = req.body;

    if (type === 'Public' && !isAdmin) {
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to create public events!'
        );
    }

    const eventCreator = tokenUser;
    if (!eventHost) {
      // Event host will be set to event creator by default
      eventHost = tokenUser.username;
    }

    const newEvent = new Event({
      title,
      type,
      description,
      eventHost,
      eventCreator,
      startDateTime,
      endDateTime,
      location,
    });

    try {
      const requiredProperties = [
        'title',
        'type',
        'startDateTime',
        'endDateTime',
        'location',
      ];
      const missingProperties = requiredProperties.filter(
        (property) => !req.body[property]
      );

      if (missingProperties.length > 0) {
        return res.status(400).json({
          error: `The following properties are required: ${missingProperties.join(
            ', '
          )}`,
        });
      }

      if (startDateTime > endDateTime) {
        return res.status(400).json({
          message:
            'The start date and time must be before the end date and time!',
        });
      } else if (startDateTime === endDateTime) {
        return res.status(400).json({
          message: 'The start date and time cannot be the same!',
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
  } catch (error) {
    console.error('Error creating event:', error);
    return res
      .status(500)
      .json({ error: 'Error creating event', details: error });
  }
};

exports.searchEvent = async (req, res) => {
  const { title, eventCreator, eventHost, startDateTime, location } = req.body;

  if (!(title || eventCreator || eventHost || startDateTime || location)) {
    return res
      .status(400)
      .json({ error: 'You must provide at least one search parameter.' });
  }

  try {
    const query = {};
    let regex;
    query.type = 'Public'; // Search function only looks for public events

    if (title) {
      regex = new RegExp(title, 'i');
      query.title = { $regex: regex };
    }

    if (eventCreator) {
      regex = new RegExp(eventCreator, 'i');
      query.eventCreator = { $regex: regex };
    }

    if (eventHost) {
      regex = new RegExp(eventHost, 'i');
      query.eventHost = { $regex: regex };
    }

    if (startDateTime) {
      const start = new Date(startDateTime);
      start.setUTCHours(0, 0, 0, 0);

      const end = new Date(startDateTime);
      end.setUTCHours(23, 59, 59, 999);

      query.startDateTime = { $gte: start, $lte: end };

      console.log('Start:', start);
      console.log('End:', end);
      console.log('Query:', query);
    }

    if (location) {
      regex = new RegExp(location, 'i');
      query.location = { $regex: regex };
    }

    const events = await Event.find(query);

    if (events.length > 0) {
      return res.status(200).json(events);
    }

    return res.status(404).json({ error: 'No events found' });
  } catch (error) {
    return res
      .status(500)
      .json({ error: 'An error occurred while searching for events.' });
  }
};

exports.getById = async (req, res) => {
  const givenEventId = req.body._id;
  let event;

  if (!givenEventId) {
    return res.status(400).json({ error: 'Event ID not provided' });
  }

  try {
    event = await Event.findById(givenEventId).select();

    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }
  } catch (error) {
    return res.status(500).json({ message: error.message });
  }
  return res.status(200).json({ event });
};

exports.deleteEvent = async (req, res) => {
  // Private events can only be deleted by the creator or admins
  try {
    const currentUser = await userController.extractAndDecodeToken(req);
    const tokenUserId = currentUser.data._id;
    const tokenUser = await User.findById(tokenUserId);

    const givenEventId = req.body._id;

    if (!givenEventId) {
      return res.status(400).json({ error: 'Event ID not provided' });
    }

    const event = await Event.findById(givenEventId);
    
    if (!event) {
      return res.status(404).json({ error: 'Event not found' });
    }
    
    if (event.eventCreator.toString() !== tokenUserId.toString() && !tokenUser.isAdmin) {
      // This case should be impossible reach in practice ngl
      return res
        .status(403)
        .json(
          'Administrative priviledges are required to delete private events you have not created!'
        );
    }

    try {
      await Event.findByIdAndDelete(givenEventId);
      return res.status(200).json('Event has been deleted');
    } catch (error) {
      return res.status(500).json(error);
    }
  } catch (error) {
    console.error('Error deleting event:', error);
    return res
      .status(500)
      .json({ error: 'Error deleting event', details: error });
  }
};
