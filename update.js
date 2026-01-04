#!/usr/bin/env node
/**
 * Football Home - Data Update Orchestrator
 * 
 * Queries scrape_targets table and runs appropriate scrapers.
 * Can be run manually or via cron job.
 */

const { Pool } = require('pg');
const { spawn } = require('child_process');
const path = require('path');

// Color codes for output
const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  red: '\x1b[31m',
};

/**
 * Run a Node.js scraper
 */
async function runScraper(scraperPath, args = []) {
  return new Promise((resolve, reject) => {
    console.log(`${colors.blue}  → Running: ${scraperPath}${colors.reset}`);
    
    const scraper = spawn('node', [scraperPath, ...args], {
      cwd: path.dirname(scraperPath),
      stdio: 'inherit'
    });
    
    scraper.on('close', (code) => {
      if (code === 0) {
        resolve();
      } else {
        reject(new Error(`Scraper exited with code ${code}`));
      }
    });
    
    scraper.on('error', (err) => {
      reject(err);
    });
  });
}

/**
 * Main orchestrator
 */
async function main() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'footballhome',
    user: process.env.DB_USER || 'footballhome_user',
    password: process.env.DB_PASSWORD || 'footballhome_pass',
  });
  
  try {
    console.log(`${colors.yellow}📋 Querying scrape_targets table...${colors.reset}`);
    
    // Get all active scrape targets
    const result = await pool.query(`
      SELECT 
        st.id,
        st.label,
        st.url,
        st.target_type_id,
        stt.name as target_type_name,
        st.scraper_type_id,
        scrt.name as scraper_type_name,
        st.source_system_id,
        ss.name as source_system_name,
        st.is_initialized,
        st.last_synced_at
      FROM scrape_targets st
      JOIN scrape_target_types stt ON st.target_type_id = stt.id
      JOIN scraper_types scrt ON st.scraper_type_id = scrt.id
      JOIN source_systems ss ON st.source_system_id = ss.id
      WHERE st.is_active = true
      ORDER BY st.id
    `);
    
    if (result.rows.length === 0) {
      console.log(`${colors.yellow}  No active scrape targets found${colors.reset}`);
      console.log(`${colors.blue}  Add targets to scrape_targets table to enable scraping${colors.reset}`);
      return;
    }
    
    console.log(`${colors.green}  Found ${result.rows.length} active target(s)${colors.reset}`);
    console.log('');
    
    const stats = {
      total: result.rows.length,
      success: 0,
      failed: 0,
      skipped: 0
    };
    
    // Process each target
    for (const target of result.rows) {
      console.log(`${colors.blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
      console.log(`${colors.yellow}Target: ${target.label}${colors.reset}`);
      console.log(`  Type: ${target.target_type_name}`);
      console.log(`  Source: ${target.source_system_name}`);
      console.log(`  Last synced: ${target.last_synced_at || 'Never'}`);
      console.log('');
      
      try {
        // Route to appropriate scraper based on target_type_id and source_system_id
        const mode = target.is_initialized ? 'sync' : 'discover';
        
        // Countries (REST Countries API)
        if (target.target_type_id === 17 && target.source_system_id === 6) {
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/CountryScraperV2.js'),
            [mode]
          );
          stats.success++;
        }
        // APSL conference structure
        else if (target.target_type_id === 1 && target.source_system_id === 1) {
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/ApslStructureScraper.js')
          );
          stats.success++;
        }
        // Add more scrapers here as they're built
        else {
          console.log(`${colors.yellow}  ⚠ No scraper implemented for this target type yet${colors.reset}`);
          stats.skipped++;
        }
        
        console.log('');
      } catch (error) {
        console.error(`${colors.red}  ✗ Failed: ${error.message}${colors.reset}`);
        stats.failed++;
        console.log('');
      }
    }
    
    // Summary
    console.log(`${colors.blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
    console.log(`${colors.yellow}Summary:${colors.reset}`);
    console.log(`  Total targets:  ${stats.total}`);
    console.log(`  ${colors.green}✓${colors.reset} Success:      ${stats.success}`);
    if (stats.failed > 0) {
      console.log(`  ${colors.red}✗${colors.reset} Failed:       ${stats.failed}`);
    }
    if (stats.skipped > 0) {
      console.log(`  ${colors.yellow}⚠${colors.reset} Skipped:      ${stats.skipped}`);
    }
    
    if (stats.failed > 0) {
      process.exit(1);
    }
    
  } catch (error) {
    console.error(`${colors.red}Orchestrator error: ${error.message}${colors.reset}`);
    console.error(error.stack);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = { main };
