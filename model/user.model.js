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
            type: String,
            default:""
        },
        bonds: {
            type:Array,
            default:[]
        },
        numOfBonds: {
            type: Number,
            default:0
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


const userModel = db.model('user',userSchema);

module.exports = userModel;