const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;


const websiteSchema = new Schema({
        totalClickCount:{
            type:Number,
            default: 0
        },
    }, {timestamps:true} //createdAt, updatedAt
);

const website = db.model('website',websiteSchema);

module.exports = website;