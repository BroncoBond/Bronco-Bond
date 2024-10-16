const mongoose = require('mongoose');
const db = require('../config/db');
const { Schema } = mongoose;

const organizationSchema = new Schema(
  {
    name: {
      type: String,
      min: 3,
      max: 20,
      unique: true,
      required: true,
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
      enum: ['Club', 'Fraternity', 'Sorority'], // The type must match these hard-coded types of Organizations
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
