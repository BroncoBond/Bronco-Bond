const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;

const commentSchema = new Schema({
    user: {
        type: mongoose.Schema.Types.ObjectId,
        ref:'User',
        required: true
    },
    text: {
        type: String,
        required: true
    },
    timestamp: {
        type: Date,
        default: Date.now,
        required: true
    }
}
);

const comment = db.model('Comment', commentSchema);

module.exports = comment;