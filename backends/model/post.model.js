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
            type: Number,
            default: 0
        },

        // We could have a feature here where like you could see who liked the post
        likedBy: [{
            type: mongoose.Schema.Types.ObjectId,
            ref:'User',
            default: []
        }],

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


        // Not sure how forms of media are modelled, can have multiple media maybe, cap at a number of media
        media: {
            type: Buffer // this would be for storing an image directly
        },
        // Or maybe like this?
        mediaPath: {
            type: String // This would be for storing a media's link/path
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
            required: true
        },

        // Allow private (only you), friends (only your friends), or public (everyone) posts?
        visibility: {
            type: String,
            enum: ['Private', 'Friends', 'Public'], 
            required: true
        },

        // Might need a way to see every user who saved the specific post?
        savedBy: [{
            user: {
                type: mongoose.Schema.Types.ObjectId,
                ref:'User',
                default: []
            }
        }],

        // Might need a way to store every user who has hidden the post, or maybe blocked the author?
        hiddenBy: [{
            user: {
                type: mongoose.Schema.Types.ObjectId,
                ref:'User',
                default: []
            }
        }],
    }, {timestamps:true} //createdAt, updatedAt
);

const post = db.model('Post', postSchema);

module.exports = post;