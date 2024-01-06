const mongoose = require('mongoose');
const dotenv = require("dotenv");

dotenv.config();

const connection = mongoose.createConnection(process.env.MONGO_URL,).on('open',()=> {
        console.log("MongoDb Connected")
    }).on('error',(err)=>{
        console.log("MongoDb Connection Error", err);
    });



module.exports = connection;

