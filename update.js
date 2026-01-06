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
    console.log(`${colors.yellow}📋 Querying scrape_targets table (state machine)...${colors.reset}`);
    
    // Get all active scrape targets, respecting state machine
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
        st.scrape_action_id,
        sa.name as action_name,
        st.scrape_status_id,
        sst.name as status_name,
        st.is_initialized,
        st.last_synced_at
      FROM scrape_targets st
      JOIN scrape_target_types stt ON st.target_type_id = stt.id
      JOIN scraper_types scrt ON st.scraper_type_id = scrt.id
      JOIN source_systems ss ON st.source_system_id = ss.id
      LEFT JOIN scrape_actions sa ON st.scrape_action_id = sa.id
      LEFT JOIN scrape_statuses sst ON st.scrape_status_id = sst.id
      WHERE st.is_active = true
        AND (sa.name IS NULL OR sa.name != 'skip')           -- Don't process 'skip' actions
        AND (sst.name IS NULL OR sst.name NOT IN ('archived', 'in_progress'))  -- Don't process archived or already running
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
      console.log(`  Action: ${target.action_name || 'download_and_parse (default)'}`);
      console.log(`  Status: ${target.status_name || 'not_started (default)'}`);
      console.log(`  Last synced: ${target.last_synced_at || 'Never'}`);
      console.log('');
      
      // Mark as in_progress
      await pool.query(
        'UPDATE scrape_targets SET scrape_status_id = 2 WHERE id = $1',
        [target.id]
      );
      
      const startTime = Date.now();
      let success = false;
      let errorMessage = null;
      
      try {
        // Route to appropriate scraper based on target_type_id and source_system_id
        const mode = target.is_initialized ? 'sync' : 'discover';
        
        // Determine if we should use cache based on scrape_action
        // 1=download_and_parse (fetch fresh), 2=use_cache_only, 4=force_refresh (fetch fresh)
        const useCache = target.action_name === 'use_cache_only';
        
        // Set environment variables for scraper
        process.env.SCRAPE_TARGET_ID = target.id;
        process.env.SCRAPE_USE_CACHE = useCache ? 'true' : 'false';
        
        // Countries (REST Countries API) - target_type_id=17, source_system_id=6
        if (target.target_type_id === 17 && target.source_system_id === 6) {
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/CountryScraperV2.js'),
            [mode]
          );
          
          // After loading countries, automatically run US States scraper
          console.log('');
          console.log(`${colors.blue}  → Running dependent scraper: UsStatesScraper.js${colors.reset}`);
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/UsStatesScraper.js')
          );
          
          success = true;
          stats.success++;
        }
        // Governing Bodies (static JSON) - target_type_id=18, source_system_id=7
        else if (target.target_type_id === 18 && target.source_system_id === 7) {
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/GoverningBodyScraper.js'),
            [mode]
          );
          success = true;
          stats.success++;
        }
        // APSL conference structure - target_type_id=1, source_system_id=1
        else if (target.target_type_id === 1 && target.source_system_id === 1) {
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/ApslStructureScraper.js')
          );
          
          // After structure scrape, run roster scraper to populate players
          console.log('');
          console.log(`${colors.blue}  → Running dependent scraper: ApslRosterScraper.js${colors.reset}`);
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/ApslRosterScraper.js')
          );
          
          // After roster scrape, run match scraper to populate matches
          console.log('');
          console.log(`${colors.blue}  → Running dependent scraper: ApslMatchScraper.js${colors.reset}`);
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/ApslMatchScraper.js')
          );
          
          // After match scrape, run date scraper to populate match dates
          console.log('');
          console.log(`${colors.blue}  → Running dependent scraper: ApslMatchDateScraper.js${colors.reset}`);
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/ApslMatchDateScraper.js')
          );
          
          // After dates, run lineup scraper to populate match lineups
          console.log('');
          console.log(`${colors.blue}  → Running dependent scraper: ApslLineupScraper.js${colors.reset}`);
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/ApslLineupScraper.js')
          );
          
          // After lineups, run match event scraper to populate match events
          console.log('');
          console.log(`${colors.blue}  → Running dependent scraper: ApslMatchEventScraper.js${colors.reset}`);
          await runScraper(
            path.join(__dirname, 'database/scripts/scrapers/ApslMatchEventScraper.js')
          );
          
          success = true;
          stats.success++;
        }
        // Add more scrapers here as they're built
        else {
          console.log(`${colors.yellow}  ⚠ No scraper implemented for this target type yet${colors.reset}`);
          success = true; // Not an error, just not implemented
          stats.skipped++;
        }
        
        console.log('');
      } catch (error) {
        console.error(`${colors.red}  ✗ Failed: ${error.message}${colors.reset}`);
        success = false;
        errorMessage = error.message;
        stats.failed++;
        console.log('');
      } finally {
        const duration = Date.now() - startTime;
        
        // Update target status and action based on success
        if (success) {
          // On success: Mark complete and set action to 'skip' so it won't re-run
          await pool.query(
            `UPDATE scrape_targets 
             SET scrape_action_id = 3,  -- 3=skip (completed, don't re-run)
                 scrape_status_id = 3,  -- 3=completed
                 last_success_at = CURRENT_TIMESTAMP,
                 is_initialized = true,
                 last_synced_at = CURRENT_TIMESTAMP,
                 updated_at = CURRENT_TIMESTAMP,
                 retry_count = 0
             WHERE id = $1`,
            [target.id]
          );
        } else {
          // On failure: Mark failed, keep action unchanged, increment retry count
          await pool.query(
            `UPDATE scrape_targets 
             SET scrape_status_id = 5,  -- 5=failed
                 last_error_at = CURRENT_TIMESTAMP,
                 last_error_message = $1,
                 retry_count = retry_count + 1,
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = $2`,
            [errorMessage, target.id]
          );
        }
        
        // Record execution in scrape_executions table
        const executionStatusId = success ? 3 : 5;  // 3=success, 5=failed
        await pool.query(
          `INSERT INTO scrape_executions 
           (scrape_target_id, status_id, started_at, completed_at, duration_ms, error_message)
           VALUES ($1, $2, to_timestamp($3::double precision / 1000), CURRENT_TIMESTAMP, $4, $5)`,
          [target.id, executionStatusId, startTime, duration, errorMessage]
        );
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
