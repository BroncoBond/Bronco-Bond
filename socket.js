module.exports = function(io) {
    console.log("SocketJS: ")

    io.on('connection', (socket) => {
        console.log('User Connected');

        socket.on('chat message', (msg) => {
            console.log('User Message: ' + msg);
            io.emit('chat message', msg);
        });

        socket.on('disconnect', () => {
            console.log('User Disconnected');
        });
    });
};