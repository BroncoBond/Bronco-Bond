const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;

const calendarSchema = new Schema(
  {
    userID: { // User associated with the calendar
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
    },
    events: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Event',
        default: [],
      },
    ],
  },
  { timestamps: true }
);

const Calendar = db.model('Calendar', calendarSchema);

module.exports = Calendar;
