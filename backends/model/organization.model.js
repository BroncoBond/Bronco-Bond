const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

const db = require('../config/db');

const { Schema } = mongoose;

const organizationSchema = new Schema(
  {
    name: {
      type: String,
      required: true,
      min: 3,
      max: 20,
      unique: true,
    },
    logo: {
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
      enum: ['Club', 'Fraternities', 'Sororities'], // The type must match these hard-coded types of Organizations
      required: true,
    },
    followers: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        default: [],
      },
    ],
    numOfFollowers: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

const Organization = db.model('Organization', organizationSchema);

module.exports = Organization;
