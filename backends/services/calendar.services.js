const Calendar = require('../model/calendar.model');
require('dotenv').config();

class CalendarService {
  // Checks if the user has a calendar for older accounts. Likely applicable only in development.
  static async checkCalendar(_id) {
    try {
      const calendar = await Calendar.findOne({ userId: _id });
      if (!calendar) {
        this.createCalendar(_id);
      }
      return { message: 'User successfully checked for calendar' };
    } catch (error) {
      return { message: error.message };
    }
  }

  static async createCalendar(_id) {
    const newCalendar = new Calendar({ userId: _id });
    try {
      await newCalendar.save();
      console.log('Calendar created successfully');
      return newCalendar;
    } catch (error) {
      return { message: error.message };
    }
  }

  static async addEvent(_id, eventId) {
    const calendar = await Calendar.findOne({ userId: _id });
    try {
      await calendar.updateOne({
        $push: { events: eventId },
      });
      return { message: 'Event added to calendar' };
    } catch (error) {
      return { message: error.message };
    }
  }

  static async removeEvent(_id, eventId) {
    const calendar = await Calendar.findOne({ userId: _id });
    try {
      await calendar.updateOne({
        $pull: { events: eventId },
      });
      return { message: 'Event removed from calendar' };
    } catch (error) {
      return { message: error.message };
    }
  }
}

module.exports = CalendarService;
