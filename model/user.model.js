const mongoose = require('mongoose');
const bcrypt = require("bcrypt");

const db = require('../config/db');

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
        is_online:{
            type:String,
            default: '0'
        },
        fullName:{
            type:String,
            lowercase:true
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
        bondRequestsToUser: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            default:[]
        }],
        bondRequestsFromUser: [{
            type: mongoose.Schema.Types.ObjectId,
            ref: 'User',
            default:[]
        }],
        numOfBonds: {
            type: Number,
            default:0
        },
        interests: {
            type: [String],
            default:[]
        },
        isAdmin: {
            type: Boolean,
            default: false,
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
        graduationDate: {
            type: String,
            default: new Date().getFullYear()
        },
        tokens: [{ type: Object }]
    },
    {timestamps:true}
);

userSchema.pre('save', async function(next) {
    try {
        const salt = await bcrypt.genSalt(10);
        const hashpass = await bcrypt.hash(this.password, salt);
        this.password = hashpass;
        next();
    } catch (error) {
        next(error);
    }
});

userSchema.methods.comparePassword = async function(userPassword){
    try {
        const isMatch = await bcrypt.compare(userPassword,this.password);
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