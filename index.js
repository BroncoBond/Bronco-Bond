const express = require('express');
const app = express();
const http = require('http');
const server = http.createServer(app);
const {Server} = require('socket.io');
const io = new Server(server);
const socketSetup = require('./socket');


app.get('/', (req, res) => {
  res.sendFile(__dirname + '/index.html');
});

server.listen(3001, () => {
  console.log('listening on *:3001');
});

socketSetup(io);
