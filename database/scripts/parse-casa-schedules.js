#!/usr/bin/env node
/**
 * CASA Schedule Parser
 * Parse matches from JavaScript-rendered schedule pages using Puppeteer
 * Generates SQL file: database/data/043-matches-casa.sql
 */

const fs = require('fs');
const puppeteer = require('puppeteer');

// Division mapping from database/data/034-divisions.sql
const DIVISIONS = [
  { id: 54, name: 'Philadelphia Liga 1', external_id: '9090889' },
  { id: 55, name: 'Philadelphia Liga 2', external_id: '9096430' },
  { id: 56, name: 'Boston Liga 1', external_id: '9090891' },
  { id: 57, name: 'Lancaster Liga 1', external_id: '9090893' }
];

async function parseSchedulePage(browser, external_id, divisionName) {
  const page = await browser.newPage();
  
  try {
    const url = `https://www.casasoccerleagues.com/season_management_season_page/tab_schedule?page_node_id=${external_id}`;
    console.log(`  Fetching: ${url}`);
    
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });
    
    // Wait for initial load
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    // Auto-scroll to trigger lazy loading of content
    console.log(`  📜 Auto-scrolling to load all matches...`);
    for (let i = 0; i < 5; i++) {
      await page.evaluate(() => {
        window.scrollTo(0, document.body.scrollHeight);
        
        // Also scroll any scrollable containers
        const containers = document.querySelectorAll('[style*="overflow"], .scrollable, .schedule-container');
        containers.forEach(c => {
          if (c.scrollHeight > c.clientHeight) {
            c.scrollTop = c.scrollHeight;
          }
        });
      });
      
      // Wait between scrolls
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    // Scroll back to top to capture full page
    await page.evaluate(() => window.scrollTo(0, 0));
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Check for iframes
    const frames = page.frames();
    console.log(`  Found ${frames.length} frames on page`);
    
    // Save screenshot
    await page.screenshot({ 
      path: `database/scraped-html/casa/schedule-${external_id}-screenshot.png`,
      fullPage: true 
    });
    
    // Try to extract from iframe first
    let matches = [];
    for (const frame of frames) {
      const frameUrl = frame.url();
      if (frameUrl.includes('schedule') || frameUrl.includes('season')) {
        console.log(`  Checking frame: ${frameUrl.substring(0, 100)}...`);
        
        // Wait for schedule content to load
        await new Promise(resolve => setTimeout(resolve, 3000));
        
        // Save frame HTML for debugging
        const frameHtml = await frame.content();
        fs.writeFileSync(`database/scraped-html/casa/schedule-${external_id}-frame.html`, frameHtml);
        
        const frameMatches = await frame.evaluate(() => {
          // Extract structured match data from Angular components (sm-schedule-event)
          const events = document.querySelectorAll('sm-schedule-event');
          return Array.from(events).map(event => {
            // Get away team
            const awayTeamEl = event.querySelector('[tag="away-team-name"]');
            const awayTeam = awayTeamEl ? awayTeamEl.textContent.trim() : null;
            
            // Get home team (could be inside tag or outside-home-team)
            const homeTeamEl = event.querySelector('[tag="home-team-name"]');
            const outsideHomeEl = event.querySelector('[data-cy="outside-home-team"]');
            const homeTeam = homeTeamEl ? homeTeamEl.textContent.trim() : 
                            outsideHomeEl ? outsideHomeEl.textContent.trim() : null;
            
            // Get date/time
            const timeEl = event.querySelector('[data-cy="event-time"]');
            const time = timeEl ? timeEl.textContent.trim() : null;
            
            // Get status
            const statusEl = event.querySelector('[data-cy="event-status"]');
            const status = statusEl ? statusEl.textContent.trim() : null;
            
            // Get score if available
            const scoreEl = event.querySelector('[data-cy="game-score"]');
            const score = scoreEl ? scoreEl.textContent.trim() : null;
            
            return { 
              home: homeTeam,
              away: awayTeam,
              time: time,
              status: status,
              score: score
            };
          }).filter(m => m.away && m.home);
        }).catch(err => {
          console.error(`    Frame eval error: ${err.message}`);
          return [];
        });
        
        if (frameMatches.length > 0) {
          matches = matches.concat(frameMatches);
          console.log(`    Found ${frameMatches.length} matches in iframe`);
        } else {
          console.log(`    No matches found in iframe`);
        }
      }
    }
    
    return matches;
  } finally {
    await page.close();
  }
}

async function main() {
  console.log('🏃 Parsing CASA Select schedules...\n');
  
  const browser = await puppeteer.launch({ 
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  const allMatches = [];
  const divisionMatches = {};
  
  try {
    for (const division of DIVISIONS) {
      console.log(`\n[Division ${division.id}] ${division.name}`);
      
      try {
        const matches = await parseSchedulePage(browser, division.external_id, division.name);
        
        console.log(`  ✓ Found ${matches.length} matches`);
        if (matches.length > 0) {
          console.log(`    First match: ${matches[0].home} vs ${matches[0].away}`);
          console.log(`    Last match: ${matches[matches.length - 1].home} vs ${matches[matches.length - 1].away}`);
        }
        
        divisionMatches[division.id] = matches;
        allMatches.push(...matches);
      } catch (error) {
        console.error(`  ✗ Error: ${error.message}`);
      }
      
      // Rate limit
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  } finally {
    await browser.close();
  }
  
  console.log(`\n✓ Parsed ${allMatches.length} total matches across ${DIVISIONS.length} divisions\n`);
  
  // Save match data for inspection
  const mappingData = {
    generated: new Date().toISOString(),
    total_matches: allMatches.length,
    divisions: DIVISIONS.map(d => ({
      ...d,
      match_count: divisionMatches[d.id]?.length || 0,
      matches: divisionMatches[d.id] || []
    }))
  };
  
  fs.writeFileSync('database/scraped-html/casa/division-matches.json', JSON.stringify(mappingData, null, 2));
  console.log('✓ Saved match data to database/scraped-html/casa/division-matches.json\n');
  
  console.log('📋 Next steps:');
  console.log('  1. Review division-matches.json to verify matches');
  console.log('  2. Generate SQL with proper match dates and venues');
  console.log('  3. Map team names to team IDs from database');
}

main().catch(console.error);
