const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;


const conversationSchema = new Schema({
        participants: [
            {
                type: mongoose.Schema.Types.ObjectId,
                ref:'User'
            }
        ],
        messages:[
            {
                type: mongoose.Schema.Types.ObjectId,
                ref:"Messages",
                default:[]
            }
        ]
    }, {timestamps:true} //createdAt, updatedAt
);

const conversation = db.model('Conversation',conversationSchema);

module.exports = conversation;