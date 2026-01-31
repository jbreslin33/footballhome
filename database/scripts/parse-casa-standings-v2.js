#!/usr/bin/env node
/**
 * CASA Select - Standings Parser v2
 * Uses a better waiting strategy for dynamically loaded content
 */

const puppeteer = require('puppeteer');

// Helper function to wait for iframe with longer timeout and retries
async function waitForFrame(page, timeout = 15000) {
  const startTime = Date.now();
  while (Date.now() - startTime < timeout) {
    const frames = page.frames();
    for (const frame of frames) {
      const url = frame.url();
      if (url.includes('season-microsites.ui.sportsengine.com')) {
        console.log(`  ✓ Found target iframe: ${url}`);
        return frame;
      }
    }
    await new Promise(resolve => setTimeout(resolve, 500));
  }
  throw new Error('Timeout waiting for iframe');
}

// New strategy: Wait for table to be fully rendered and stable
async function waitForTableToStabilize(frame, expectedMinRows = 5) {
  console.log(`  ⏳ Waiting for table to fully render (expecting at least ${expectedMinRows} rows)...`);
  
  let stableCount = 0;
  let previousRowCount = 0;
  const maxAttempts = 40; // 40 * 1000ms = 40 seconds total
  
  for (let attempt = 0; attempt < maxAttempts; attempt++) {
    try {
      // Check current row count
      const rowCount = await frame.evaluate(() => {
        const table = document.querySelector('table');
        if (!table) return 0;
        
        // Try to find tbody rows
        const tbody = table.querySelector('tbody');
        if (tbody) {
          return tbody.querySelectorAll('tr').length;
        }
        
        // Fallback: count all rows except header
        const allRows = table.querySelectorAll('tr');
        return allRows.length > 1 ? allRows.length - 1 : 0;
      });
      
      console.log(`    Attempt ${attempt + 1}: ${rowCount} rows visible`);
      
      // If row count hasn't changed, increment stable counter
      if (rowCount === previousRowCount && rowCount >= expectedMinRows) {
        stableCount++;
        if (stableCount >= 3) {
          console.log(`    ✓ Table stabilized with ${rowCount} rows`);
          return rowCount;
        }
      } else {
        stableCount = 0; // Reset if count changed
      }
      
      previousRowCount = rowCount;
      
      // Scroll within iframe to trigger rendering
      await frame.evaluate(() => {
        // Scroll window
        window.scrollTo(0, document.body.scrollHeight);
        
        // Find and scroll table container
        const table = document.querySelector('table');
        if (table) {
          // Try to find scrollable parent
          let parent = table.parentElement;
          let attempts = 0;
          while (parent && attempts < 5) {
            const style = window.getComputedStyle(parent);
            if (style.overflow === 'auto' || style.overflow === 'scroll' || 
                style.overflowY === 'auto' || style.overflowY === 'scroll') {
              console.log('Found scrollable parent, scrolling...');
              parent.scrollTop = parent.scrollHeight;
              break;
            }
            parent = parent.parentElement;
            attempts++;
          }
        }
      });
      
      // Wait before next check
      await new Promise(resolve => setTimeout(resolve, 1000));
      
    } catch (error) {
      console.log(`    Error in attempt ${attempt + 1}: ${error.message}`);
    }
  }
  
  console.log(`    ⚠️  Table did not stabilize, proceeding with ${previousRowCount} rows`);
  return previousRowCount;
}

// Scrape standings from a single frame
async function scrapeFrame(frame) {
  return await frame.evaluate(() => {
    const teams = [];
    const table = document.querySelector('table');
    
    if (!table) {
      return teams;
    }
    
    // Try tbody first
    let rows = table.querySelectorAll('tbody tr');
    
    // Fallback: get all rows except first (header)
    if (rows.length === 0) {
      const allRows = Array.from(table.querySelectorAll('tr'));
      rows = allRows.slice(1); // Skip header row
    }
    
    rows.forEach(row => {
      // Try multiple selectors for team name
      let teamName = null;
      
      // Strategy 1: Look for team name in specific column (usually 2nd or 3rd)
      const cells = row.querySelectorAll('td');
      if (cells.length >= 2) {
        // Try 2nd cell first (after rank)
        teamName = cells[1]?.textContent?.trim();
        
        // If empty or looks like a number, try 3rd cell
        if (!teamName || /^\d+$/.test(teamName)) {
          teamName = cells[2]?.textContent?.trim();
        }
      }
      
      // Strategy 2: Look for links (teams often have links)
      if (!teamName || teamName.length < 2) {
        const link = row.querySelector('a');
        if (link) {
          teamName = link.textContent.trim();
        }
      }
      
      // Strategy 3: Find the longest text content (likely team name)
      if (!teamName || teamName.length < 2) {
        const textsInRow = Array.from(cells).map(c => c.textContent.trim());
        teamName = textsInRow.reduce((longest, current) => 
          current.length > longest.length ? current : longest, '');
      }
      
      // Only add if we found a meaningful name
      if (teamName && teamName.length > 2 && !/^[\d.]+$/.test(teamName)) {
        teams.push(teamName);
      }
    });
    
    return teams;
  });
}

async function scrapeAllStandings() {
  console.log('🏆 CASA Select - Standings Scraper v2');
  console.log('=====================================\n');

  const divisions = [
    { id: 54, name: 'Philadelphia Liga 1', external_id: 9090889 },
    { id: 55, name: 'Philadelphia Liga 2', external_id: 9094085 },
    { id: 56, name: 'Boston Liga 1', external_id: 9090891 },
    { id: 57, name: 'Lancaster Liga 1', external_id: 9090892 },
  ];

  const browser = await puppeteer.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const allTeams = [];

  for (const division of divisions) {
    console.log(`\n📊 Scraping: ${division.name}`);
    console.log(`   URL: https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=${division.external_id}`);

    const page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });
    await page.goto(`https://www.casasoccerleagues.com/season_management_season_page/tab_standings?page_node_id=${division.external_id}`, {
      waitUntil: 'networkidle0',
      timeout: 30000
    });

    try {
      // Wait for iframe
      const frame = await waitForFrame(page);
      
      // Wait for table to fully render and stabilize
      const rowCount = await waitForTableToStabilize(frame, 5);
      console.log(`  📋 Detected ${rowCount} rows in table`);
      
      // Scrape teams
      const teams = await scrapeFrame(frame);
      
      console.log(`  ✅ Found ${teams.length} teams:`);
      teams.forEach((team, idx) => {
        console.log(`     ${idx + 1}. ${team}`);
        allTeams.push({
          division_id: division.id,
          division_name: division.name,
          team_name: team
        });
      });
      
    } catch (error) {
      console.error(`  ❌ Error: ${error.message}`);
    }

    await page.close();
  }

  await browser.close();

  console.log(`\n📊 SUMMARY`);
  console.log(`==========`);
  console.log(`Total teams found: ${allTeams.length}`);
  console.log(`\nBy division:`);
  divisions.forEach(div => {
    const count = allTeams.filter(t => t.division_id === div.id).length;
    console.log(`  ${div.name}: ${count} teams`);
  });

  console.log(`\n✅ Done!`);
  console.log(JSON.stringify(allTeams, null, 2));
}

// Run
scrapeAllStandings().catch(console.error);
