const express = require('express');
const router = express.Router();

// Database pool will be injected
let dbPool;

const setDbPool = (pool) => {
    dbPool = pool;
};

// Simple test endpoint
router.get('/test', (req, res) => {
    res.json({ message: 'Events router is working!' });
});

module.exports = { router, setDbPool };