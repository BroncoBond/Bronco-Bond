const { Server } = require("socket.io");
const http = require("http");
const express = require("express");
const Message = require('../model/message.model');
const messageController = require('../controller/message.controller');

const app = express();

const server = http.createServer(app);

const io = new Server(server, {
    cors:{
        origin: process.env.NODE_ENV !== 'development' ? 'https://broncobond.com' : 'http://localhost:8080',
        methods:["GET", "POST"]
    }
})

const getReceiverSocketId = (receiverId) => {
	return userSocketMap[receiverId];
};

const userSocketMap = {}; //{userId: socketId}

io.on("connection", (socket)=> {
    console.log("a user connected",socket.id);

    const userId = socket.handshake.query.userId;
    if (userId != "undefined") {
        userSocketMap[userId] = socket.id;
    } 

    io.emit("getOnlineUsers", Object.keys(userSocketMap));


    socket.on("sendMessage", async (data, callback) => {
        const { receiverId, messageContent } = data;
        const senderId = socket.userId;

        try {
            const newMessage = await messageController.sendMessage(senderId, receiverId, messageContent);

            const receiverSocketId = getReceiverSocketId(receiverId);
            if (receiverSocketId) {
                io.to(receiverSocketId).emit("newMessage", newMessage);
            }

            callback(null, newMessage);
        } catch (err) {
            callback(err);
        }
    });

    socket.on("disconnect",()=>{
        console.log("user disconnected",socket.id);
        delete userSocketMap[userId];
        io.emit("getOnlineUsers", Object.keys(userSocketMap));
    });
});

module.exports = {server, app, io, getReceiverSocketId};