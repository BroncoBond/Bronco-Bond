const mongoose = require('mongoose');
const dbUrl = "mongodb+srv://BroncoAdmin:QSkJ3RmcqwzVKlkO@bbound.aurjrgj.mongodb.net/?retryWrites=true&w=majority"

const connection = mongoose.createConnection(dbUrl).on('open',()=>{
    console.log("MongoDb Connected")
}).on('error',()=>{
    console.log("MongoDb Connection Error")
});


module.exports = connection;

