module.exports = (err, req, res, next) => {
    console.error('Global error handler:', err);
    res.status(500).json({ status: false, error: 'Internal Server Error' });
};