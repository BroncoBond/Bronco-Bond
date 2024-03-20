// External dependencies
const express = require('express');
const app = express();
const http = require('http');
const helmet = require('helmet');
const morgan = require('morgan');
const cors = require('cors');
const server = http.createServer(app);
const {Server} = require('socket.io');
const io = new Server(server);
const socketSetup = require('./socket');

// Internal dependencies
const userRouter = require('./routers/user.router');
const errorHandler = require('./middleware/errorHandler');
const requestDurationLogger = require('./middleware/durationLogger');

const port = process.env.WEBSITES_PORT;

// app.get('/', (req, res) => {
//     res.sendFile(__dirname + '/index.html');
//     // res.render('index', { title: 'BroncoBond', message: 'Hello World, this is BroncoBond!' });
// });

// server.listen(port, () => {
//         console.log(`Server is running on port ${port}`);
// });

// socketSetup(io);

// Middleware
app.use(express.json({ limit: process.env.JSON_LIMIT || '50mb' }));
app.use(
  helmet.contentSecurityPolicy({
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'", "'unsafe-eval'"],
      styleSrc: ["'self'", "'unsafe-inline'", 'https:', 'http:'],
      imgSrc: ["'self'", 'data:', 'blob:', 'https:', 'http:'],
      connectSrc: ["'self'", 'ws:', 'https:', 'http:'],
      fontSrc: ["'self'", 'https:', 'http:'],
      objectSrc: ["'none'"],
      upgradeInsecureRequests: [],
    },
  })
);
app.use(
  morgan('common', {
    skip: function (req, res) {
      return req.method === 'GET' && req.headers.upgrade === 'websocket';
    },
  })
);
app.use(express.static('public'));
app.use(cors());


// Routes
app.use(requestDurationLogger);
app.use('/user', userRouter);

// Error Handler
app.use(errorHandler);

// Root route
app.get('/', (req, res) => {
    res.sendFile(__dirname + '/index.html');
    // res.render('index', { title: 'BroncoBond', message: 'Hello World, this is BroncoBond!' });
});

// Start the server
startServer(port, io, server);

function startServer(port, io, server) {
    server.listen(port, () => {
        console.log(`Server is running on port ${port}`);
    });

    socketSetup(io);

    server.on('error', (error) => {
        console.error('Error starting server:', error.message);
        process.exit(1);
    });

    // Handle shutdown gracefully (optional)
    process.on('SIGINT', () => {
        server_.close(() => {
            console.log('Server is shutting down');
            process.exit(0);
        });
    });
}
/* 

    Dev Notes:

Start up:
Step 1: In terminal [npm install i --save]
Step 2: In terminal if asked do [npm fund]
Step 3: In terminal [npm init -y]
Step 4: To start server [node index.js] or [npm run dev]
Step 5: Check Frontend IP

Debug SocketIO: 
Step 1: In terminal [DEBUG=* node index.js]
Step 1: In command-prompt [set DEBUG=* && node index.js]

*/