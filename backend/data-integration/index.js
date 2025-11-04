const express = require('express');
const cron = require('node-cron');
const { Pool } = require('pg');
const winston = require('winston');
const DataIntegrationService = require('./services/DataIntegrationService');
const APSLScraper = require('./scrapers/APSLScraper');

// Configure logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' }),
    new winston.transports.Console({
      format: winston.format.simple()
    })
  ]
});

// Database connection
const db = new Pool({
  host: process.env.DB_HOST || 'database',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballuser',
  password: process.env.DB_PASSWORD || 'footballpass',
  max: 20,
  idleTimeoutMillis: 30000,
});

const app = express();
const port = process.env.PORT || 3002;

app.use(express.json());
app.use(express.static('public'));

// Initialize services
const dataIntegrationService = new DataIntegrationService(db, logger);
const apslScraper = new APSLScraper(dataIntegrationService, logger);

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'data-integration'
  });
});

// Manual sync endpoints
app.post('/sync/apsl', async (req, res) => {
  try {
    logger.info('Manual APSL sync requested');
    const result = await apslScraper.syncAllConferences();
    res.json({
      success: true,
      message: 'APSL sync completed',
      result
    });
  } catch (error) {
    logger.error('Manual APSL sync failed:', error);
    res.status(500).json({
      success: false,
      message: 'APSL sync failed',
      error: error.message
    });
  }
});

app.post('/sync/all', async (req, res) => {
  try {
    logger.info('Manual full sync requested');
    const results = await dataIntegrationService.syncAllSources();
    res.json({
      success: true,
      message: 'Full sync completed',
      results
    });
  } catch (error) {
    logger.error('Manual full sync failed:', error);
    res.status(500).json({
      success: false,
      message: 'Full sync failed',
      error: error.message
    });
  }
});

// Get sync status
app.get('/sync/status', async (req, res) => {
  try {
    const status = await dataIntegrationService.getSyncStatus();
    res.json(status);
  } catch (error) {
    logger.error('Failed to get sync status:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Get import conflicts
app.get('/conflicts', async (req, res) => {
  try {
    const conflicts = await dataIntegrationService.getUnresolvedConflicts();
    res.json(conflicts);
  } catch (error) {
    logger.error('Failed to get conflicts:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Resolve conflict
app.post('/conflicts/:conflictId/resolve', async (req, res) => {
  try {
    const { conflictId } = req.params;
    const { resolution, notes } = req.body;
    const result = await dataIntegrationService.resolveConflict(conflictId, resolution, notes);
    res.json({
      success: true,
      message: 'Conflict resolved',
      result
    });
  } catch (error) {
    logger.error('Failed to resolve conflict:', error);
    res.status(500).json({
      success: false,
      error: error.message
    });
  }
});

// Schedule automatic syncing
// Daily at 6 AM for APSL (they typically update overnight)
cron.schedule('0 6 * * *', async () => {
  try {
    logger.info('Starting scheduled APSL sync');
    await apslScraper.syncAllConferences();
    logger.info('Scheduled APSL sync completed');
  } catch (error) {
    logger.error('Scheduled APSL sync failed:', error);
  }
});

// Weekly sync on Sunday at 8 AM for other leagues
cron.schedule('0 8 * * 0', async () => {
  try {
    logger.info('Starting scheduled full sync');
    await dataIntegrationService.syncAllSources();
    logger.info('Scheduled full sync completed');
  } catch (error) {
    logger.error('Scheduled full sync failed:', error);
  }
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('Received SIGTERM, shutting down gracefully');
  await db.end();
  process.exit(0);
});

process.on('SIGINT', async () => {
  logger.info('Received SIGINT, shutting down gracefully');
  await db.end();
  process.exit(0);
});

app.listen(port, () => {
  logger.info(`Data Integration Service running on port ${port}`);
});

module.exports = app;