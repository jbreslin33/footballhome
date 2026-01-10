#!/usr/bin/env node
/**
 * Diagnose why matches have no match_events
 * 
 * Checks:
 * 1. How many matches exist
 * 2. How many have match_events
 * 3. Which HTML files exist for match event scraping
 * 4. Whether scrapers ran successfully
 * 5. What the scraper logs show
 */

const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

const colors = {
  reset: '\x1b[0m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
};

async function main() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'footballhome',
    user: process.env.DB_USER || 'footballhome_user',
    password: process.env.DB_PASSWORD || 'footballhome_pass',
  });
  
  try {
    console.log(`${colors.blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
    console.log(`${colors.cyan}   MATCH EVENTS DIAGNOSTIC REPORT${colors.reset}`);
    console.log(`${colors.blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}\n`);
    
    // 1. Check match counts by league
    console.log(`${colors.yellow}📊 MATCH COUNTS BY LEAGUE${colors.reset}`);
    console.log('─'.repeat(60));
    const matchCounts = await pool.query(`
      SELECT 
        ss.name as source,
        COUNT(m.id) as total_matches,
        COUNT(m.home_score) as matches_with_scores
      FROM matches m
      JOIN source_systems ss ON m.source_system_id = ss.id
      GROUP BY ss.name
      ORDER BY ss.name
    `);
    
    for (const row of matchCounts.rows) {
      console.log(`  ${row.source}:`);
      console.log(`    Total matches: ${row.total_matches}`);
      console.log(`    With scores:   ${row.matches_with_scores}`);
    }
    console.log('');
    
    // 2. Check match_events counts by league
    console.log(`${colors.yellow}⚽ MATCH EVENTS BY LEAGUE${colors.reset}`);
    console.log('─'.repeat(60));
    const eventCounts = await pool.query(`
      SELECT 
        ss.name as source,
        COUNT(DISTINCT me.match_id) as matches_with_events,
        COUNT(me.id) as total_events,
        SUM(CASE WHEN met.name = 'goal' THEN 1 ELSE 0 END) as goals,
        SUM(CASE WHEN met.name = 'assist' THEN 1 ELSE 0 END) as assists
      FROM match_events me
      JOIN matches m ON me.match_id = m.id
      JOIN source_systems ss ON m.source_system_id = ss.id
      JOIN match_event_types met ON me.event_type_id = met.id
      GROUP BY ss.name
      ORDER BY ss.name
    `);
    
    if (eventCounts.rows.length === 0) {
      console.log(`  ${colors.red}❌ NO MATCH EVENTS FOUND IN DATABASE${colors.reset}`);
    } else {
      for (const row of eventCounts.rows) {
        console.log(`  ${row.source}:`);
        console.log(`    Matches with events: ${row.matches_with_events}`);
        console.log(`    Total events:        ${row.total_events}`);
        console.log(`    Goals:               ${row.goals}`);
        console.log(`    Assists:             ${row.assists}`);
      }
    }
    console.log('');
    
    // 3. Check HTML files exist
    console.log(`${colors.yellow}📁 HTML FILES FOR MATCH EVENTS${colors.reset}`);
    console.log('─'.repeat(60));
    
    const apslDir = path.join(__dirname, '../scraped-html/apsl');
    const cslDir = path.join(__dirname, '../scraped-html/csl');
    
    let apslCount = 0;
    let cslCount = 0;
    
    if (fs.existsSync(apslDir)) {
      const files = fs.readdirSync(apslDir);
      apslCount = files.filter(f => f.match(/^apsl-event-\d+.*\.html$/)).length;
    }
    
    if (fs.existsSync(cslDir)) {
      const files = fs.readdirSync(cslDir);
      cslCount = files.filter(f => f.match(/^\d+-.*\.html$/)).length;
    }
    
    console.log(`  APSL event HTML files: ${apslCount}`);
    console.log(`  CSL event HTML files:  ${cslCount}`);
    console.log('');
    
    // 4. Check scrape_executions for match event scrapers
    console.log(`${colors.yellow}📝 SCRAPER EXECUTION HISTORY${colors.reset}`);
    console.log('─'.repeat(60));
    const executions = await pool.query(`
      SELECT 
        st.label,
        sst.name as status,
        se.started_at,
        se.duration_ms,
        se.error_message
      FROM scrape_executions se
      JOIN scrape_targets st ON se.scrape_target_id = st.id
      JOIN scrape_statuses sst ON se.status_id = sst.id
      WHERE st.label ILIKE '%event%' OR st.label ILIKE '%match%'
      ORDER BY se.started_at DESC
      LIMIT 10
    `);
    
    if (executions.rows.length === 0) {
      console.log(`  ${colors.yellow}⚠️  No scraper execution history found${colors.reset}`);
    } else {
      for (const row of executions.rows) {
        const statusColor = row.status === 'completed' ? colors.green : colors.red;
        console.log(`  ${statusColor}${row.status}${colors.reset} - ${row.label}`);
        console.log(`    Started: ${row.started_at}`);
        console.log(`    Duration: ${row.duration_ms}ms`);
        if (row.error_message) {
          console.log(`    Error: ${row.error_message}`);
        }
      }
    }
    console.log('');
    
    // 5. Check sample matches missing events
    console.log(`${colors.yellow}🔍 SAMPLE MATCHES WITHOUT EVENTS${colors.reset}`);
    console.log('─'.repeat(60));
    const sampleMatches = await pool.query(`
      SELECT 
        m.id,
        m.external_id,
        ss.name as source,
        ht.name as home_team,
        at.name as away_team,
        m.home_score,
        m.away_score,
        m.match_date
      FROM matches m
      JOIN source_systems ss ON m.source_system_id = ss.id
      JOIN teams ht ON m.home_team_id = ht.id
      JOIN teams at ON m.away_team_id = at.id
      LEFT JOIN match_events me ON m.id = me.match_id
      WHERE m.home_score IS NOT NULL
        AND me.id IS NULL
      ORDER BY m.match_date DESC
      LIMIT 5
    `);
    
    if (sampleMatches.rows.length === 0) {
      console.log(`  ${colors.green}✅ All matches with scores have events!${colors.reset}`);
    } else {
      for (const row of sampleMatches.rows) {
        console.log(`  ${row.source} - Match ${row.id} (external: ${row.external_id})`);
        console.log(`    ${row.home_team} ${row.home_score} - ${row.away_score} ${row.away_team}`);
        console.log(`    Date: ${row.match_date}`);
        
        // Check if HTML exists for this match
        let htmlExists = false;
        if (row.source === 'APSL') {
          const filename = `apsl-event-${row.external_id}.html`;
          htmlExists = fs.existsSync(path.join(apslDir, filename));
        } else if (row.source === 'CSL') {
          const files = fs.readdirSync(cslDir);
          htmlExists = files.some(f => f.startsWith(`${row.external_id}-`));
        }
        
        console.log(`    HTML exists: ${htmlExists ? colors.green + '✓' + colors.reset : colors.red + '✗' + colors.reset}`);
        console.log('');
      }
    }
    
    // 6. Recommendations
    console.log(`${colors.blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}`);
    console.log(`${colors.cyan}💡 RECOMMENDATIONS${colors.reset}`);
    console.log(`${colors.blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${colors.reset}\n`);
    
    if (eventCounts.rows.length === 0) {
      console.log(`${colors.yellow}1. Match event scrapers may not have run yet${colors.reset}`);
      console.log(`   Run: ./update.sh`);
      console.log('');
      console.log(`${colors.yellow}2. Or check if HTML files were downloaded:${colors.reset}`);
      if (apslCount === 0) {
        console.log(`   ${colors.red}✗${colors.reset} No APSL HTML files found - need to download`);
      }
      if (cslCount === 0) {
        console.log(`   ${colors.red}✗${colors.reset} No CSL HTML files found - need to download`);
      }
      console.log('');
      console.log(`${colors.yellow}3. Or run scrapers manually:${colors.reset}`);
      console.log(`   node database/scripts/scrapers/ApslMatchEventScraper.js`);
      console.log(`   node database/scripts/scrapers/CslMatchEventScraper.js`);
    } else {
      const totalMatchesWithScores = matchCounts.rows.reduce((sum, r) => sum + parseInt(r.matches_with_scores), 0);
      const totalMatchesWithEvents = eventCounts.rows.reduce((sum, r) => sum + parseInt(r.matches_with_events), 0);
      const coverage = Math.round((totalMatchesWithEvents / totalMatchesWithScores) * 100);
      
      console.log(`Coverage: ${totalMatchesWithEvents}/${totalMatchesWithScores} matches (${coverage}%)`);
      
      if (coverage < 100) {
        console.log('');
        console.log(`${colors.yellow}Some matches missing events - possible causes:${colors.reset}`);
        console.log(`  - HTML files not downloaded for those matches`);
        console.log(`  - HTML parsing failed (no player stats in source)`);
        console.log(`  - Player name matching failed`);
      } else {
        console.log('');
        console.log(`${colors.green}✅ All matches have events - looking good!${colors.reset}`);
      }
    }
    
    console.log('');
    
  } catch (error) {
    console.error(`${colors.red}Error: ${error.message}${colors.reset}`);
    console.error(error.stack);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

// Run
main();
