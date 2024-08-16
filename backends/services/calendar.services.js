const Calendar = require('../model/calendar.model');

class CalendarService {
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
}

module.exports = CalendarService;
