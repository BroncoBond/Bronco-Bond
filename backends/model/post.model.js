const db = require('../config/db');
const mongoose = require('mongoose');
const { Schema } = mongoose;

const postSchema = new Schema({
        title: {
            type: String,
            required: true
        },
        body: {
            type: String,
            required: true
        },
        author: {
            type: mongoose.Schema.Types.ObjectId,
            ref:'User',
            required: true
        },
        tags: {
            type: [String],
            default: []
        },
        
        likes: {
            type: Array,
            default: []
        },

        //Note - likes should be an array; if a users like the post, the user's ID should be added to the array

        // // We could have a feature here where like you could see who liked the post
        // likedBy: [{
        //     type: mongoose.Schema.Types.ObjectId,
        //     ref:'User',
        //     default: []
        // }],

        // Model in a model basically?
        comments: [{
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
        }],
        commentsCount: {
            type: Number,
            default: 0
        },

        media: {
            data: Buffer,
            contentType: String,
        },
        mediaCount: {
            type: Number,
            default: 0
        },

        // Not sure how this works but maybe we need to define a link automatically to the current post here?
        shareLink: {
            type: String,
            required: true
        },
        shareCount: {
            type: Number,
            default: 0
        },
        impressions: {
            type: Number,
            default: 0
        },

        // Maybe allow users to make drafts of posts before posting them?
        status: {
            type: String,
            enum: ['Draft', 'Published'],
            default: 'Draft'
        },

        // Allow private (only you), friends (only your friends), or public (everyone) posts?
        visibility: {
            type: String,
            enum: ['Private', 'Friends', 'Public'], 
            default: 'Friends',
        },

        // Might need a way to see every user who saved the specific post?
        savedBy: [{
            type: Array,
            default: []
        }],

        // Might need a way to store every user who has hidden the post, or maybe blocked the author?
        hiddenBy: [{
            type: mongoose.Schema.Types.ObjectId,
            ref:'User',
            default: []
        }],
    }, {timestamps:true} //createdAt, updatedAt
);

const post = db.model('Post', postSchema);

module.exports = post;