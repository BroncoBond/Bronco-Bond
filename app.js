const express = require('express');
const bodyParser = require('body-parser');
const userRouter = require('./routers/user.router');

const app = express();

app.use(bodyParser.json());

app.use('/api',userRouter);

module.exports = app;