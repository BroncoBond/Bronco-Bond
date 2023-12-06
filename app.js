const express = require('express');
const bodyParser = require('body-parser');
const userRouter = require('./routers/user.router');

const app = express();

// Middileware
app.use(bodyParser.json());

// Routes
app.use('/',userRouter);

// Global Error Handler
app.use((err, req, res, next) => {
    console.error('Global error handler:', err);
    res.status(500).json({ status: false, error: 'Internal Server Error' });
});


module.exports = app;