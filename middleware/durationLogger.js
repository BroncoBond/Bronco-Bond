const { performance } = require('perf_hooks');

function requestDurationLogger(req, res, next) {
    const start = performance.now();

    res.on('finish', () => {
        const end = performance.now();
        const duration = end - start;
        console.log(`Request ${req.method} ${req.path} took ${duration.toFixed(2)} milliseconds`);
    });

    next();
}

module.exports = requestDurationLogger;
