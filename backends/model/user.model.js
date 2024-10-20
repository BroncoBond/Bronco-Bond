const db = require('../config/db');
const mongoose = require('mongoose');
const bcrypt = require("bcrypt");
const { Schema } = mongoose;

const userSchema = new Schema({
        email:{
            type:String,
            lowercase:true,
            required: true,
            max: 50,
            unique: true
        },
        username:{
            type:String,
            required: true,
            min: 3,
            max: 20,
            unique: true
        },
        password:{
            type:String,
            min: 6,
            required: true
        },
        isOnline:{
            type:Boolean,
            default: '0'
        },
        fullName:{
            type:String
        },
        prefName:{
            type:String
        },
        profilePicture: {
            data: Buffer,
            contentType: String
        },
        bonds: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            default:[]
        }],
        bondRequestsReceived: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            default:[]
        }],
        bondRequestsSent: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            default:[]
        }],
        numOfBonds: {
            type: Number,
            default:0
        },
        pronouns: {
            type: String,
            lowercase:true,
            default: "Prefer Not To Say"
        },
        gender: {
            type: String,
            lowercase:true,
            default: "Prefer Not To Say"
        },
        followedOrganizations: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Organization',
            default: []
        }],
        numOfFollowedOrganizations: {
            type: Number,
            default: 0
        },
        eventInterests: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Event',
            default: []
        }],
        numOfEventInterests: {
            type: Number,
            default: 0
        },
        interests: { // This "interest" is specifically for a user's interests (activities, hobbies, etc.)
            type: [String],
            default:[]
        },
        calendar: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Calendar'
        },
        isAdmin: {
            type: Boolean,
            default: false
        },
        descriptionMajor: {
            type: String,
            default: "Undeclared"
        },
        descriptionMinor: {
            type: String
        },
        descriptionBio: {
            type: String,
            max: 50,
            default:"Im new BroncoBond!"
        },
        clubList: {
            type: [String],
            default:[]
        },
        graduationDate: {
            type: String,
            default: (() => {
                let currentYear = new Date().getFullYear();
                return (currentYear + 4).toString();
            })()
        },
        isVerified: {
            type: Boolean,
            default: false
        },
        tokens: [{ type: Object }]
    }, {timestamps:true} 
);

userSchema.pre('save', async function(next) {
    if (!this.isModified('password')) {
        return next();
    }
    
    try {
        const salt = await bcrypt.genSalt(10);
        const hashpass = await bcrypt.hash(this.password, salt);
        this.password = hashpass;
        next();
    } catch (error) {
        next(error);
    }
});

userSchema.methods.comparePassword = function(userPassword){
    try {
        console.log("Comparing password: " + this.password);
        console.log("Comparing entered password: " + userPassword);
        const isMatch = bcrypt.compareSync(userPassword,this.password);
        return isMatch;
    } catch (error) {
        throw error;
    }
}

userSchema.statics.searchUserByEmail = async function (email) {
    try {
        const user = await this.findOne({ email });
        return user;
    } catch (error) {
        throw error;
    }
};


const User = db.model('User',userSchema);

module.exports = User;