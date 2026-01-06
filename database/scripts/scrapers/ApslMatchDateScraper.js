const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');
const { JSDOM } = require('jsdom');

/**
 * APSL Match Date Scraper
 * 
 * Parses team schedule HTML files to extract match dates.
 * Updates matches table with real dates from team roster pages.
 * 
 * Team HTML files contain schedule tables with:
 * - Cell 1: Date/time (e.g., "Sunday, Sep 14 - 6:00 PM")
 * - Cell 4: Result with event link (e.g., "Win (3 - 0) (view)" with link to /APSL/Event/228142)
 */
class ApslMatchDateScraper {
  constructor(client) {
    this.client = client;
    this.cacheDir = path.join(__dirname, '../../scraped-html/apsl');
    this.dateMapping = new Map(); // eventId -> date
  }
  
  async run() {
    console.log(`\n📅 APSL Match Date Scraper`);
    console.log('='.repeat(60));
    
    try {
      // Get all team HTML files
      const files = fs.readdirSync(this.cacheDir)
        .filter(f => f.startsWith('apsl-team-') && f.endsWith('.html'));
      
      console.log(`📋 Found ${files.length} team files to process\n`);
      
      // Parse dates from each team file
      for (const file of files) {
        const htmlPath = path.join(this.cacheDir, file);
        const html = fs.readFileSync(htmlPath, 'utf-8');
        this.parseTeamSchedule(html);
      }
      
      console.log(`📊 Extracted dates for ${this.dateMapping.size} matches\n`);
      
      // Update matches table
      let updated = 0;
      let notFound = 0;
      
      for (const [eventId, matchDate] of this.dateMapping) {
        try {
          const result = await this.client.query(
            `UPDATE matches 
             SET match_date = $1
             WHERE source_system_id = 1 
               AND external_id = $2`,
            [matchDate, eventId]
          );
          
          if (result.rowCount > 0) {
            updated++;
          } else {
            notFound++;
          }
        } catch (error) {
          console.error(`   ⚠️  Error updating match ${eventId}: ${error.message}`);
        }
      }
      
      console.log(`✅ Date update completed`);
      console.log(`   Updated: ${updated}`);
      console.log(`   Not found in DB: ${notFound}`);
      
    } catch (error) {
      console.error(`\n❌ Scraper error: ${error.message}`);
      console.error(error.stack);
      throw error;
    }
  }
  
  /**
   * Parse team schedule HTML to extract date + event ID pairs
   */
  parseTeamSchedule(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    const rows = document.querySelectorAll('tr');
    
    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 4) continue;
      
      const dateCell = cells[0];
      const resultCell = cells[3];
      
      // Extract date from cell 1
      const dateText = dateCell.textContent.trim();
      if (!this.isDatePattern(dateText)) continue;
      
      // Extract event ID from cell 4
      const eventLink = resultCell.querySelector('a[href*="Event"]');
      if (!eventLink) continue;
      
      const href = eventLink.getAttribute('href');
      const eventId = this.extractEventId(href);
      if (!eventId) continue;
      
      // Parse the date
      const matchDate = this.parseDate(dateText);
      if (!matchDate) continue;
      
      // Store mapping
      this.dateMapping.set(eventId, matchDate);
    }
  }
  
  /**
   * Check if text looks like a date pattern
   */
  isDatePattern(text) {
    return /^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday),\s+[A-Z][a-z]+\s+\d{1,2}/.test(text);
  }
  
  /**
   * Extract event ID from href
   * Example: /APSL/Event/228142_F1ADA4EE3C80B2AA7AD9C8B82E072334 -> 228142
   */
  extractEventId(href) {
    const match = href.match(/Event\/(\d+)/);
    return match ? match[1] : null;
  }
  
  /**
   * Parse date string to Date object
   * Input: "Sunday, Sep 14 - 6:00 PM" or "Sunday, Sep 14"
   * Output: Date object (assumes current year or previous year based on month)
   */
  parseDate(dateText) {
    // Extract day of week, month, and day
    const match = dateText.match(/^(Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday),\s+([A-Z][a-z]+)\s+(\d{1,2})/);
    if (!match) return null;
    
    const monthName = match[2];
    const day = parseInt(match[3], 10);
    
    // Month name to number
    const monthMap = {
      'Jan': 0, 'Feb': 1, 'Mar': 2, 'Apr': 3, 'May': 4, 'Jun': 5,
      'Jul': 6, 'Aug': 7, 'Sep': 8, 'Oct': 9, 'Nov': 10, 'Dec': 11
    };
    
    const month = monthMap[monthName];
    if (month === undefined) return null;
    
    // Determine year (soccer seasons typically Sep-May)
    // If current month is Jan-Aug and match month is Sep-Dec, use previous year
    // Otherwise use current year
    const now = new Date();
    const currentYear = now.getFullYear();
    const currentMonth = now.getMonth();
    
    let year = currentYear;
    
    // Soccer season logic: Sep-Dec matches from fall, Jan-May from spring
    if (month >= 8) { // Sep-Dec
      // If we're in Jan-Aug, these Sep-Dec matches are from previous year
      if (currentMonth < 8) {
        year = currentYear - 1;
      }
    } else { // Jan-Aug
      // If we're in Sep-Dec, these Jan-Aug matches are from next year
      if (currentMonth >= 8) {
        year = currentYear + 1;
      }
    }
    
    return new Date(year, month, day);
  }
}

/**
 * Main entry point
 */
async function main() {
  const pool = new Pool({
    host: process.env.DB_HOST || 'localhost',
    port: process.env.DB_PORT || 5432,
    database: process.env.DB_NAME || 'footballhome',
    user: process.env.DB_USER || 'footballhome_user',
    password: process.env.DB_PASSWORD || 'footballhome_pass',
  });
  
  let client;
  try {
    client = await pool.connect();
    const scraper = new ApslMatchDateScraper(client);
    await scraper.run();
  } catch (error) {
    console.error('Fatal error:', error);
    process.exit(1);
  } finally {
    if (client) client.release();
    await pool.end();
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = ApslMatchDateScraper;
