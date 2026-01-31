#!/usr/bin/env node
/**
 * CASA Roster Parser
 * Parses Google Sheets rosters from Captain's Corner to extract teams
 * Generates SQL file: database/data/042b-teams-casa.sql
 */

const fs = require('fs');
const puppeteer = require('puppeteer');
const { parse } = require('csv-parse/sync');

async function fetchGoogleSheetWithPuppeteer(browser, url) {
  const page = await browser.newPage();
  
  try {
    // Visit the actual Google Sheets page (not CSV export)
    await page.goto(url, { waitUntil: 'networkidle2', timeout: 30000 });
    
    // Wait for the spreadsheet to render
    await page.waitForSelector('.waffle', { timeout: 10000 }).catch(() => {});
    
    // Extract visible cell data from the rendered spreadsheet
    const cellData = await page.evaluate(() => {
      const cells = [];
      const rows = document.querySelectorAll('.waffle tr');
      
      for (let i = 0; i < Math.min(10, rows.length); i++) {
        const row = rows[i];
        const cellElements = row.querySelectorAll('td');
        const rowData = [];
        
        for (const cell of cellElements) {
          const text = cell.textContent.trim();
          if (text) rowData.push(text);
        }
        
        if (rowData.length > 0) {
          cells.push(rowData);
        }
      }
      
      return cells;
    });
    
    // Convert to CSV-like format
    const csvData = cellData.map(row => row.join(',')).join('\n');
    
    return csvData;
  } finally {
    await page.close();
  }
}

function parseTeamFromRoster(csvData) {
  if (!csvData || csvData.length < 3) {
    return null;
  }
  
  const lines = csvData.split('\n');
  
  // Look for team name in first few rows
  for (let i = 0; i < Math.min(5, lines.length); i++) {
    const line = lines[i];
    const lower = line.toLowerCase();
    
    // Skip header rows
    if (lower.includes('player') || lower.includes('name') || lower.includes('position') || lower.includes('jersey')) {
      continue;
    }
    
    // Pattern: "Team: Name" or "Team Name"
    if (lower.includes('team')) {
      const match = line.match(/team[:\s]+([^,]+)/i);
      if (match) {
        return match[1].trim();
      }
    }
    
    // First non-empty cell might be team name
    const firstCell = line.split(',')[0].trim();
    if (firstCell && firstCell.length > 3 && firstCell.length < 50) {
      // Looks like a team name
      return firstCell;
    }
  }
  
  return null;
}

async function main() {
  console.log('🏃 Parsing CASA Select rosters from Google Sheets...\n');
  
  // Extract sheet URLs from Captain's Corner HTML
  const captainsCornerHtml = fs.readFileSync('database/scraped-html/casa/captains-corner.html', 'utf8');
  const sheetUrls = captainsCornerHtml.match(/https:\/\/docs\.google\.com\/spreadsheets\/[^"]+/g) || [];
  
  console.log(`Found ${sheetUrls.length} roster sheets in Captain's Corner`);
  console.log('Launching browser...\n');
  
  const browser = await puppeteer.launch({ 
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  
  const teams = [];
  
  try {
    // Fetch and parse each sheet
    for (let i = 0; i < sheetUrls.length; i++) {
      const url = sheetUrls[i];
      console.log(`[${i + 1}/${sheetUrls.length}] Fetching roster...`);
      
      try {
        const csvData = await fetchGoogleSheetWithPuppeteer(browser, url);
        const teamName = parseTeamFromRoster(csvData);
        
        if (teamName) {
          console.log(`  ✓ Found team: ${teamName}`);
          teams.push(teamName);
          
          // Save CSV for debugging
          const filename = `database/scraped-html/casa/roster-${i + 1}.csv`;
          fs.writeFileSync(filename, csvData);
        } else {
          console.log(`  ⚠ Could not parse team name from roster`);
          // Save for manual inspection
          const filename = `database/scraped-html/casa/roster-${i + 1}-unknown.csv`;
          fs.writeFileSync(filename, csvData);
        }
      } catch (error) {
        console.error(`  ✗ Error fetching roster: ${error.message}`);
      }
      
      // Rate limit
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
  } finally {
    await browser.close();
  }
  
  console.log(`\n✓ Parsed ${teams.length} teams from ${sheetUrls.length} rosters\n`);
  
  // Generate SQL
  const sqlHeader = `-- CASA Select Teams (2025/2026 Season)
-- Generated: ${new Date().toISOString().split('T')[0]}
-- Source: Google Sheets rosters from Captain's Corner
-- Teams parsed: ${teams.length}

`;

  const sqlInserts = teams.length > 0 
    ? teams.map(teamName => {
        const escaped = teamName.replace(/'/g, "''");
        return `INSERT INTO teams (name, source_system_id) VALUES ('${escaped}', 2) ON CONFLICT (source_system_id, name) DO NOTHING;`;
      }).join('\n')
    : '-- No teams parsed - check CSV files in database/scraped-html/casa/';
  
  const sqlFooter = `\n\n-- Update sequence
SELECT setval('teams_id_seq', (SELECT COALESCE(MAX(id), 0) FROM teams));
`;
  
  const sql = sqlHeader + sqlInserts + sqlFooter;
  fs.writeFileSync('database/data/042b-teams-casa.sql', sql);
  
  console.log('✓ Generated database/data/042b-teams-casa.sql');
  console.log(`  ${teams.length} team INSERT statements\n`);
  
  if (teams.length === 0) {
    console.log('⚠ No teams found - check *-unknown.csv files in database/scraped-html/casa/');
  } else {
    console.log('📋 Next steps:');
    console.log('  1. Review generated SQL file');
    console.log('  2. Run ./build.sh to load teams into database');
    console.log('  3. Parse standings/schedules to create matches');
  }
}

main().catch(console.error);
