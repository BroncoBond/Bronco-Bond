// External dependencies
const express = require('express');
const bodyParser = require('body-parser');
const helmet = require("helmet");
const morgan = require("morgan");

// Internal dependencies
const db = require('./config/db');
const UserModel = require('./model/user.model');
const userRouter = require('./routers/user.router');
const errorHandler = require('./middleware/errorHandler');
const durationLogger = require('./middleware/durationLogger');
const requestDurationLogger = require('./middleware/durationLogger');

const app = express();
const port = process.env.WEBSITES_PORT || process.env.PORT;

// Middleware
app.use(express.json({ limit: process.env.JSON_LIMIT || '50mb' }));
app.use(helmet());
app.use(morgan("common"));
app.use(express.static('public'));

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