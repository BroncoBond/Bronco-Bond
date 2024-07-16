const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const db = require('../config/db');

const { Schema } = mongoose;

const eventSchema = new Schema(
  {
    title: {
      type: String,
      min: 1,
      max: 20,
      required: true,
    },
    image: {
      data: Buffer,
      contentType: String,
    },
    description: {
      type: String,
      max: 300,
      default: 'No description.',
    },
    type: {
      type: String,
      enum: ['Public', 'Private'], // The type must match these hard-coded types of Organizations
      required: true,
    },
    eventCreator: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User'
      },
    ],
  },
  { timestamps: true }
);

const event = db.model('Events', eventSchema);

module.exports = event;
