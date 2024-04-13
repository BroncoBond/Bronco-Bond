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
        message:[
            {
                type: mongoose.Schema.Types.ObjectId,
                ref:"Message",
                default:[]
            }
        ]
    }, {timestamps:true} //createdAt, updatedAt
);

const conversation = db.model('Conversation',conversationSchema);

module.exports = conversation;