#!/usr/bin/env node

/**
 * Sync APSL standings data from their website
 * Usage: npm run sync-apsl
 */

const { Pool } = require('pg');
const winston = require('winston');
const DataIntegrationService = require('../services/DataIntegrationService');
const APSLScraper = require('../scrapers/APSLScraper');

// Configure logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.errors({ stack: true }),
    winston.format.simple()
  ),
  transports: [
    new winston.transports.Console()
  ]
});

// Database connection
const db = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'footballhome',
  user: process.env.DB_USER || 'footballuser',
  password: process.env.DB_PASSWORD || 'footballpass',
});

async function syncAPSL() {
  try {
    logger.info('Starting APSL sync script...');
    
    const dataService = new DataIntegrationService(db, logger);
    const apslScraper = new APSLScraper(dataService, logger);
    
    // Test connection first
    const connectionTest = await apslScraper.testConnection();
    if (!connectionTest.success) {
      throw new Error(`Connection test failed: ${connectionTest.message}`);
    }
    
    logger.info('Connection test successful, proceeding with sync...');
    
    // Perform the sync
    const results = await apslScraper.syncAllConferences();
    
    // Display results
    console.log('\n=== SYNC RESULTS ===');
    results.forEach(result => {
      console.log(`${result.conference}: ${result.status}`);
      if (result.status === 'success') {
        console.log(`  - Teams found: ${result.teamsFound}`);
        console.log(`  - Records processed: ${result.processed}`);
        console.log(`  - Records inserted: ${result.inserted}`);
        console.log(`  - Records updated: ${result.updated}`);
        if (result.failed > 0) {
          console.log(`  - Records failed: ${result.failed}`);
        }
      } else {
        console.log(`  - Error: ${result.error}`);
      }
    });
    
    const totalSuccess = results.filter(r => r.status === 'success').length;
    const totalFailed = results.filter(r => r.status === 'error').length;
    
    console.log(`\nSummary: ${totalSuccess} conferences synced successfully, ${totalFailed} failed`);
    
    logger.info('APSL sync script completed successfully');
    process.exit(0);
    
  } catch (error) {
    logger.error('APSL sync script failed:', error);
    console.error('\nSync failed:', error.message);
    process.exit(1);
  } finally {
    await db.end();
  }
}

// Handle script termination
process.on('SIGINT', async () => {
  logger.info('Script interrupted, cleaning up...');
  await db.end();
  process.exit(1);
});

process.on('SIGTERM', async () => {
  logger.info('Script terminated, cleaning up...');
  await db.end();
  process.exit(1);
});

// Run the script
syncAPSL();