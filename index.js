const app = require('./app');
const db = require('./config/db');
const UserModel = require('./model/user.model');

const port = 3000 || process.env.WEBSITE_PORT;

const tryListen = () => {
    const server = app.listen(port, () => {
        console.log(`Server is running on port ${port}`);
    });

    server.on('error', (error) => {
        if (error.code === 'EADDRINUSE') {
            // Port is in use, try the next one
            console.log(`Port ${port} is already in use, trying the next one.`);
            port++;
            tryListen(); // Recursively try the next port
        } else {
            // Some other error occurred
            console.error('Error starting server:', error.message);
            process.exit(1);
        }
    });

    // Handle shutdown gracefully (optional)
    process.on('SIGINT', () => {
        server.close(() => {
            console.log('Server is shutting down');
            process.exit(0);
        });
    });
};

// Start trying to listen on the specified port
tryListen();

app.get('/', (req, res) => {
    res.send("Hello World!!");
});