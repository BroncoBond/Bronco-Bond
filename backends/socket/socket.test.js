const io = require('socket.io-client');
let expect;

before(function () {
    return import('chai').then(chai => {
        expect = chai.expect;
    });
});

describe('Socket.IO Tests', function() {
    let clientSocket;

    beforeEach(function(done) {
        // Setup
        clientSocket = io.connect('http://localhost:8080'); // Replace with your server's address and port
        clientSocket.on('connect', done);
    });

    afterEach(function(done) {
        // Cleanup
        if(clientSocket.connected) {
            clientSocket.disconnect();
        }
        done();
    });

    it('should receive a newMessage when the `sendMessage` event is emitted', function (done) {
        clientSocket.on('newMessage', (message) => {
            expect(message).to.be.an('object');
            expect(message).to.have.property('senderId');
            expect(message).to.have.property('receiverId');
            expect(message).to.have.property('message');
            done();
        });

        clientSocket.emit('sendMessage', { receiverId: 'testReceiver', messageContent: 'Hello, world!' });
    });
});