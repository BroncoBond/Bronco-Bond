// External dependencies
const express = require('express');
const helmet = require("helmet");
const morgan = require("morgan");
var http = require("http");
const cors = require("cors");

// Internal dependencies
const userRouter = require('./routers/user.router');
const errorHandler = require('./middleware/errorHandler');
const requestDurationLogger = require('./middleware/durationLogger');

const app = express();
const port = process.env.WEBSITES_PORT || process.env.PORT;
var server = http.createServer(app);
var io = require("socket.io")(server,{
    cors: {
        origin:"*"
    }
});

// Middleware
app.use(express.json({ limit: process.env.JSON_LIMIT || '50mb' }));
app.use(helmet());
app.use(morgan("common"));
app.use(express.static('public'));
app.use(cors());

//io socket
io.on("Connection",(socket)=>{
    console.log("connected");
});

// Set EJS as the view engine
app.set('view engine', 'ejs');

// Routes
app.use(requestDurationLogger);
app.use('/user', userRouter);

// Error Handler
app.use(errorHandler);

// Root route
app.get('/', (req, res) => {
    res.render('index', { title: 'BroncoBond', message: 'Hello World, this is BroncoBond!' });
});

// Start the server
startServer(port);

function startServer(port) {
    const server = app.listen(port, () => {
        console.log(`Server is running on port ${port}`);
    });

    server.on('error', (error) => {
        console.error('Error starting server:', error.message);
        process.exit(1);
    });

    // Handle shutdown gracefully (optional)
    process.on('SIGINT', () => {
        server.close(() => {
            console.log('Server is shutting down');
            process.exit(0);
        });
    });
}

/* 

    Dev Notes:
Step 1: In terminal [npm install i --save]
Step 2: In terminal if asked do [npm fund]
Step 3: In terminal [npm init -y]
Step 4: To start server [node index.js] or [npm run dev]
Step 5: Check Frontend IP

*/