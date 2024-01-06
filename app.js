const express = require('express');
const bodyParser = require('body-parser');
const userRouter = require('./routers/user.router');
const helmet = require("helmet");
const morgan = require("morgan");

const app = express();

// Middileware
app.use(express.json());
app.use(helmet());
app.use(morgan("common"));

// Routes
app.use('/user',userRouter);

// Global Error Handler
app.use((err, req, res, next) => {
    console.error('Global error handler:', err);
    res.status(500).json({ status: false, error: 'Internal Server Error' });
});


module.exports = app;


/* 
    Dev Notes:
Step 1: In terminal [npm install express body-parser mongoose bcrypt jsonwebtoken nodemon --save]
Step 2: In terminal if asked do [npm fund]
Step 3: In terminal [npm init -y]
Step 4: To start server [node index.js] or [npm run dev]
Step 5: Check Frontend IP
*/