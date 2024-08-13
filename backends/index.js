// External dependencies
const express = require('express');
const bodyParser = require('body-parser');
const helmet = require('helmet');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');

// Internal dependencies
const db = require('./config/db');
const UserModel = require('./model/user.model');
const userRouter = require('./routers/user.router');
const organizationRouter = require('./routers/organization.router');
const professorRouter = require('./routers/professor.router');
const messageRouter = require('./routers/message.router');
const eventRouter = require('./routers/event.router');
const websiteRouter = require('./routers/website.router');
const errorHandler = require('./middleware/errorHandler');
const durationLogger = require('./middleware/durationLogger');
const requestDurationLogger = require('./middleware/durationLogger');
const rateLimit = require("./middleware/rateLimiter.js")

// const app = express();
const { app, server } = require('./socket/socket.js');
const port = process.env.WEBSITES_PORT;

// Middleware
app.use(express.json({ limit: process.env.JSON_LIMIT || '50mb' }));
app.use(helmet());
app.use(morgan('common'));
app.use(express.static('public'));
app.use(express.static('views'));
app.use(cookieParser());
app.use(rateLimit);

// Set EJS as the view engine
app.set('view engine', 'ejs');

// Routes
app.use(requestDurationLogger);
app.use('/api/user',rateLimit, userRouter);
app.use('/api/organization', organizationRouter);
app.use('/api/professor', professorRouter);
app.use('/api/message', messageRouter);
app.use('/api/website', websiteRouter);
app.use('/api/event', eventRouter);
// Error Handler
app.use(errorHandler);

// Root route
app.get('/', (req, res) => {
  res.render('index', {
    title: 'BroncoBond',
    message: 'Hello World, this is BroncoBond!',
  });
});

// Start the server
startServer(port);

function startServer(port) {
  const serverIndex = server.listen(port, () => {
    console.log(`Server is running on port ${port}`);
  });

  serverIndex.on('error', (error) => {
    console.error('Error starting server:', error.message);
    process.exit(1);
  });

  // Handle shutdown gracefully (optional)
  process.on('SIGINT', () => {
    serverIndex.close(() => {
      console.log('Server is shutting down');
      process.exit(0);
    });
  });
}

/*

    Dev Notes:
Step 1: npm run build
Step 2: npm run dev

*/
