const app = require('./app');
const db = require('./config/db');
const UserModel = require('./model/user.model');

const port = process.env.WEBSITES_PORT || 3000;


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

app.get('/', (req, res) => {
    res.send("Hello World!!");
});