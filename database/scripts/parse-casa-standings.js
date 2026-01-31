#!/usr/bin/env node
/**
 * CASA Standings Parser
 * Parse team names from JavaScript-rendered standings pages using Puppeteer
 * Generates SQL file: database/data/042b-teams-casa.sql
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

async function parseStandingsPage(browser, external_id, divisionName) {
  const page = await browser.newPage();
  
  try {
    const url = `https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=${external_id}`;
    console.log(`  Fetching: ${url}`);
    
    await page.goto(url, { waitUntil: 'domcontentloaded', timeout: 60000 });
    
    // Wait for initial load
    await new Promise(resolve => setTimeout(resolve, 5000));
    
    // Auto-scroll to trigger lazy loading of content
    console.log(`  📜 Auto-scrolling to load all content...`);
    for (let i = 0; i < 10; i++) {
      await page.evaluate(() => {
        window.scrollTo(0, document.body.scrollHeight);
        
        // Also scroll any scrollable containers
        const containers = document.querySelectorAll('[style*="overflow"], .scrollable, .table-container');
        containers.forEach(c => {
          if (c.scrollHeight > c.clientHeight) {
            c.scrollTop = c.scrollHeight;
          }
        });
      });
      
      // Wait between scrolls
      await new Promise(resolve => setTimeout(resolve, 1500));
    }
    
    // Also scroll inside iframes to load their content
    const frames = page.frames();
    console.log(`  Found ${frames.length} frames, scrolling each...`);
    for (const frame of frames) {
      try {
        for (let i = 0; i < 10; i++) {
          await frame.evaluate(() => {
            window.scrollTo(0, document.body.scrollHeight);
          });
          await new Promise(resolve => setTimeout(resolve, 1000));
        }
      } catch (e) {
        // Frame might not be accessible
      }
    }
    
    // Scroll back to top to capture full page
    await page.evaluate(() => window.scrollTo(0, 0));
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    // Check for iframes again
    console.log(`  Re-checking ${frames.length} frames after scrolling`);
    
    // Wait for standings content in iframes to fully load
    await new Promise(resolve => setTimeout(resolve, 3000));
    
    // Save screenshot for debugging
    const screenshotPath = `database/scraped-html/casa/standings-${external_id}-screenshot.png`;
    await page.screenshot({ path: screenshotPath, fullPage: true });
    console.log(`  📸 Screenshot saved`);
    
    // Save HTML after scrolling
    const html = await page.content();
    fs.writeFileSync(`database/scraped-html/casa/standings-${external_id}-rendered.html`, html);
    
    // Try to extract from iframe first
    let teams = [];
    for (const frame of frames) {
      const frameUrl = frame.url();
      if (frameUrl.includes('standing') || frameUrl.includes('division') || frameUrl.includes('season')) {
        console.log(`  Checking frame: ${frameUrl}`);
        
        // Scroll the iframe content to load all table rows
        try {
          for (let i = 0; i < 10; i++) {
            await frame.evaluate(() => {
              // Scroll the main window
              window.scrollTo(0, document.body.scrollHeight);
              
              // Find and scroll the standings table container
              const tables = document.querySelectorAll('table');
              tables.forEach(table => {
                // Scroll the table itself
                table.scrollTop = table.scrollHeight;
                
                // Scroll parent containers
                let parent = table.parentElement;
                while (parent && parent !== document.body) {
                  if (parent.scrollHeight > parent.clientHeight) {
                    parent.scrollTop = parent.scrollHeight;
                  }
                  parent = parent.parentElement;
                }
              });
              
              // Also try scrolling any explicit scroll containers
              const scrollContainers = document.querySelectorAll('[style*="overflow"], .table-container, .standings-container');
              scrollContainers.forEach(c => {
                if (c.scrollHeight > c.clientHeight) {
                  c.scrollTop = c.scrollHeight;
                }
              });
            });
            await new Promise(resolve => setTimeout(resolve, 500));
          }
        } catch (e) {
          console.error(`    Error scrolling frame: ${e.message}`);
        }
        
        const frameTeams = await frame.evaluate(() => {
          const teamNames = new Set();
          const tables = document.querySelectorAll('table');
          
          for (const table of tables) {
            const rows = table.querySelectorAll('tr');
            
            for (const row of rows) {
              const cells = row.querySelectorAll('td, th');
              
              // Standings typically: Rank, Team, GP, W, D, L, GF, GA, GD, Pts
              for (let i = 0; i < Math.min(3, cells.length); i++) {
                const text = cells[i].textContent.trim();
                
                if (text && 
                    text.length > 3 && 
                    text.length < 50 &&
                    !text.match(/^\d+$/) && 
                    !text.match(/^(rank|team|gp|pts|w|d|l|gf|ga|gd|pld|played)$/i)) {
                  
                  // Check if it looks like a team name
                  if (text.match(/FC|SC|United|City|Athletic|Club/i) ||
                      (i === 1 && cells.length >= 8)) {
                    teamNames.add(text);
                  }
                }
              }
            }
          }
          
          return Array.from(teamNames);
        }).catch(() => []);
        
        if (frameTeams.length > 0) {
          teams = teams.concat(frameTeams);
          console.log(`    Found ${frameTeams.length} teams in iframe`);
        }
      }
    }
    
    // If no teams in iframes, try main page
    if (teams.length === 0) {
      teams = await page.evaluate(() => {
        const teamNames = new Set();
        
        // Look for tables
        const tables = document.querySelectorAll('table');
        
        for (const table of tables) {
          const rows = table.querySelectorAll('tr');
          
          for (const row of rows) {
            const cells = row.querySelectorAll('td, th');
            
            // Standings typically: Rank, Team, GP, W, D, L, GF, GA, GD, Pts
            // Team name is usually in column 1 or 2
            for (let i = 0; i < Math.min(3, cells.length); i++) {
              const text = cells[i].textContent.trim();
              
              // Filter: length 3-50, not a number, not a header keyword
              if (text && 
                  text.length > 3 && 
                  text.length < 50 &&
                  !text.match(/^\d+$/) && 
                  !text.match(/^(rank|team|gp|pts|w|d|l|gf|ga|gd|pld|played)$/i)) {
                
                // Check if it looks like a team name
                if (text.match(/FC|SC|United|City|Athletic|Club/i) ||
                    (i === 1 && cells.length >= 8)) { // 2nd column in wide table
                  teamNames.add(text);
                }
              }
            }
          }
        }
        
        return Array.from(teamNames);
      });
    }
    
    return teams;
  } finally {
    await page.close();
  }
}

async function main() {
  console.log('🏃 Parsing CASA Select teams from standings pages...\n');
  
  const browser = await puppeteer.launch({ 
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  const allTeams = new Set();
  const divisionTeams = {};
  
  try {
    for (const division of DIVISIONS) {
      console.log(`\n[Division ${division.id}] ${division.name}`);
      
      try {
        const teams = await parseStandingsPage(browser, division.external_id, division.name);
        
        console.log(`  ✓ Found ${teams.length} teams`);
        teams.forEach(team => {
          console.log(`    - ${team}`);
          allTeams.add(team);
        });
        
        divisionTeams[division.id] = teams;
      } catch (error) {
        console.error(`  ✗ Error: ${error.message}`);
      }
      
      // Rate limit
      await new Promise(resolve => setTimeout(resolve, 2000));
    }
  } finally {
    await browser.close();
  }
  
  console.log(`\n✓ Parsed ${allTeams.size} unique teams across ${DIVISIONS.length} divisions\n`);
  
  // Generate SQL
  const teamsArray = Array.from(allTeams).sort();
  
  const sqlHeader = `-- CASA Select Teams (2025/2026 Season)
-- Generated: ${new Date().toISOString().split('T')[0]}
-- Source: Standings pages from casasoccerleagues.com
-- Teams parsed: ${teamsArray.length}

`;

  const sqlInserts = teamsArray.length > 0
    ? teamsArray.map(teamName => {
        const escaped = teamName.replace(/'/g, "''");
        return `INSERT INTO teams (name, source_system_id) VALUES ('${escaped}', 2) ON CONFLICT (source_system_id, name) DO NOTHING;`;
      }).join('\n')
    : '-- No teams parsed';
  
  const sqlFooter = `\n\n-- Update sequence
SELECT setval('teams_id_seq', (SELECT COALESCE(MAX(id), 0) FROM teams));
`;
  
  const sql = sqlHeader + sqlInserts + sqlFooter;
  fs.writeFileSync('database/data/042b-teams-casa.sql', sql);
  
  console.log('✓ Generated database/data/042b-teams-casa.sql');
  console.log(`  ${teamsArray.length} team INSERT statements\n`);
  
  // Save division mapping for future use
  const mappingData = {
    generated: new Date().toISOString(),
    divisions: DIVISIONS.map(d => ({
      ...d,
      teams: divisionTeams[d.id] || []
    }))
  };
  
  fs.writeFileSync('database/scraped-html/casa/division-teams.json', JSON.stringify(mappingData, null, 2));
  console.log('✓ Saved division-teams mapping to database/scraped-html/casa/division-teams.json\n');
  
  console.log('📋 Next steps:');
  console.log('  1. Review generated SQL file');
  console.log('  2. Run ./build.sh to load teams');
  console.log('  3. Create division_teams junction table entries');
}

main().catch(console.error);
