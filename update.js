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
 * PHASE 1: Download all HTML files from all sources
 */
async function downloadPhase(pool, targets) {
  console.log(`${colors.yellow}📥 Downloading HTML from all sources...${colors.reset}`);
  console.log('');
  
  for (const target of targets) {
    await pool.query('UPDATE scrape_targets SET scrape_status_id = 2 WHERE id = $1', [target.id]);
    
    console.log(`${colors.blue}[${target.source_system_name.toUpperCase()}] ${target.label}${colors.reset}`);
    
    try {
      const useCache = target.action_name === 'use_cache_only';
      process.env.SCRAPE_USE_CACHE = useCache ? 'true' : 'false';
      process.env.SCRAPE_MODE = 'download';  // Tell scrapers to only download
      
      // APSL - Download standings + team pages
      if (target.target_type_id === 1 && target.source_system_id === 1) {
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/ApslStructureScraper.js'));
        console.log(`${colors.green}  ✓ Downloaded APSL structure HTML${colors.reset}\n`);
      }
      // CSL - Download standings + team pages  
      else if (target.target_type_id === 1 && target.source_system_id === 3) {
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/CslStructureScraper.js'));
        console.log(`${colors.green}  ✓ Downloaded CSL structure HTML${colors.reset}\n`);
      }
      // Countries
      else if (target.target_type_id === 17 && target.source_system_id === 6) {
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/CountryScraperV2.js'), ['discover']);
        console.log(`${colors.green}  ✓ Downloaded country data${colors.reset}\n`);
      }
      // Governing Bodies
      else if (target.target_type_id === 18 && target.source_system_id === 7) {
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/GoverningBodyScraper.js'), ['discover']);
        console.log(`${colors.green}  ✓ Loaded governing body data${colors.reset}\n`);
      }
      else {
        console.log(`${colors.yellow}  ⚠️  No downloader implemented yet${colors.reset}\n`);
      }
    } catch (error) {
      console.error(`${colors.red}  ✗ Download failed: ${error.message}${colors.reset}\n`);
    }
  }
  
  console.log(`${colors.green}✓ Download phase complete${colors.reset}`);
}

/**
 * PHASE 2: Parse all cached files and save to database
 */
async function parsePhase(pool, targets) {
  const stats = {
    total: targets.length,
    success: 0,
    failed: 0,
    skipped: 0
  };
  
  for (const target of targets) {
    console.log(`${colors.blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
    console.log(`${colors.yellow}Target: ${target.label}${colors.reset}`);
    console.log(`  Source: ${target.source_system_name}`);
    console.log('');
    
    const startTime = Date.now();
    let success = false;
    let errorMessage = null;
    
    try {
      const mode = target.is_initialized ? 'sync' : 'discover';
      process.env.SCRAPE_TARGET_ID = target.id;
      process.env.SCRAPE_MODE = 'parse';  // Tell scrapers to only parse cached files
      
      // Countries
      if (target.target_type_id === 17 && target.source_system_id === 6) {
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/CountryScraperV2.js'), [mode]);
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/UsStatesScraper.js'));
        success = true;
        stats.success++;
      }
      // Governing Bodies
      else if (target.target_type_id === 18 && target.source_system_id === 7) {
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/GoverningBodyScraper.js'), [mode]);
        success = true;
        stats.success++;
      }
      // APSL - Parse everything from cached HTML
      else if (target.target_type_id === 1 && target.source_system_id === 1) {
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/ApslStructureScraper.js'));
        console.log('');
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/ApslRosterScraper.js'));
        console.log('');
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/ApslMatchScraper.js'));
        console.log('');
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/ApslMatchDateScraper.js'));
        console.log('');
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/ApslLineupScraper.js'));
        success = true;
        stats.success++;
      }
      // CSL - Parse everything from cached HTML
      else if (target.target_type_id === 1 && target.source_system_id === 3) {
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/CslStructureScraper.js'));
        console.log('');
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/CslRosterScraper.js'));
        console.log('');
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/CslMatchScraper.js'));
        console.log('');
        await runScraper(path.join(__dirname, 'database/scripts/scrapers/CslMatchEventScraper.js'));
        success = true;
        stats.success++;
      }
      else {
        console.log(`${colors.yellow}  ⚠ No parser implemented yet${colors.reset}`);
        success = true;
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
      
      // Update target status
      if (success) {
        await pool.query(
          `UPDATE scrape_targets 
           SET scrape_action_id = 3, scrape_status_id = 3, last_success_at = CURRENT_TIMESTAMP,
               is_initialized = true, last_synced_at = CURRENT_TIMESTAMP,
               updated_at = CURRENT_TIMESTAMP, retry_count = 0
           WHERE id = $1`,
          [target.id]
        );
      } else {
        await pool.query(
          `UPDATE scrape_targets 
           SET scrape_status_id = 5, last_error_at = CURRENT_TIMESTAMP,
               last_error_message = $1, retry_count = retry_count + 1,
               updated_at = CURRENT_TIMESTAMP
           WHERE id = $2`,
          [errorMessage, target.id]
        );
      }
      
      // Record execution
      const executionStatusId = success ? 3 : 5;
      await pool.query(
        `INSERT INTO scrape_executions 
         (scrape_target_id, status_id, started_at, completed_at, duration_ms, error_message)
         VALUES ($1, $2, to_timestamp($3::double precision / 1000), CURRENT_TIMESTAMP, $4, $5)`,
        [target.id, executionStatusId, startTime, duration, errorMessage]
      );
    }
  }
  
  // Run match event scraper ONCE for all APSL matches
  const apslTargetsProcessed = stats.success > 0 || stats.failed > 0;
  if (apslTargetsProcessed) {
    console.log('');
    console.log(`${colors.blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
    console.log(`${colors.blue}  → Running ApslMatchEventScraper.js${colors.reset}`);
    try {
      await runScraper(path.join(__dirname, 'database/scripts/scrapers/ApslMatchEventScraper.js'));
      console.log(`${colors.green}  ✓ Match events processed${colors.reset}`);
    } catch (error) {
      console.error(`${colors.red}  ✗ Failed: ${error.message}${colors.reset}`);
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
  
  return stats;
}

/**
 * Main orchestrator - TWO PHASE APPROACH
 * Phase 1: Download ALL HTML files from all sources
 * Phase 2: Parse ALL cached files and write to database
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
    
    // ========================================================================
    // PHASE 1: DOWNLOAD ALL HTML FILES
    // ========================================================================
    console.log(`${colors.blue}╔════════════════════════════════════════════════════════════╗${colors.reset}`);
    console.log(`${colors.blue}║  PHASE 1: DOWNLOADING ALL HTML FILES                      ║${colors.reset}`);
    console.log(`${colors.blue}╚════════════════════════════════════════════════════════════╝${colors.reset}`);
    console.log('');
    
    await downloadPhase(pool, result.rows);
    
    // ========================================================================
    // PHASE 2: PARSE AND SAVE TO DATABASE
    // ========================================================================
    console.log('');
    console.log(`${colors.blue}╔════════════════════════════════════════════════════════════╗${colors.reset}`);
    console.log(`${colors.blue}║  PHASE 2: PARSING AND SAVING TO DATABASE                  ║${colors.reset}`);
    console.log(`${colors.blue}╚════════════════════════════════════════════════════════════╝${colors.reset}`);
    console.log('');
    
    const stats = await parsePhase(pool, result.rows);
    
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
