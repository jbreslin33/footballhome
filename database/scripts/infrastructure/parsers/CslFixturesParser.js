const { JSDOM } = require('jsdom');

/**
 * Parser for Cosmopolitan Soccer League fixtures/schedule pages
 * Extracts match information (date, teams, scores)
 */
class CslFixturesParser {
  /**
   * Parse fixtures HTML to extract matches
   * @param {string} html - Raw HTML from fixtures page
   * @returns {Array<{homeTeam: string, awayTeam: string, homeScore: number|null, awayScore: number|null, date: string, externalId: string}>}
   */
  parse(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    const matches = [];
    
    // Look for match rows in tables or divs
    // CSL typically structures matches in table rows or card-style divs
    const tables = document.querySelectorAll('table');
    
    for (const table of tables) {
      const rows = table.querySelectorAll('tbody tr');
      
      for (const row of rows) {
        const match = this.parseMatchRow(row);
        if (match) {
          matches.push(match);
        }
      }
    }
    
    return matches;
  }
  
  /**
   * Parse a single match row
   * @param {Element} row - Table row element
   * @returns {Object|null} Match data or null if invalid
   */
  parseMatchRow(row) {
    const cells = row.querySelectorAll('td');
    if (cells.length < 3) return null;
    
    // Try to find team names and score
    // Common patterns:
    // - "Team A vs Team B" with score in another cell
    // - "Team A 2 - 1 Team B"
    
    let homeTeam = null;
    let awayTeam = null;
    let homeScore = null;
    let awayScore = null;
    let date = null;
    let externalId = null;
    
    // Look for links to match statistics (contains external ID)
    const links = row.querySelectorAll('a[href*="/Event/"]');
    if (links.length > 0) {
      const href = links[0].getAttribute('href');
      const match = href.match(/\/Event\/(\d+_[A-F0-9]+)/);
      if (match) {
        externalId = match[1];
      }
    }
    
    // Parse team names from cell text
    for (let i = 0; i < cells.length; i++) {
      const text = cells[i].textContent.trim();
      
      // Look for "Team A vs Team B" or "Team A - Team B" pattern
      if (text.includes(' vs ') || text.includes(' - ')) {
        const parts = text.split(/\s+vs\s+|\s+-\s+/);
        if (parts.length === 2) {
          homeTeam = parts[0].trim();
          awayTeam = parts[1].trim();
        }
      }
      
      // Look for score pattern "2 - 1" or "2:1"
      const scoreMatch = text.match(/(\d+)\s*[-:]\s*(\d+)/);
      if (scoreMatch) {
        homeScore = parseInt(scoreMatch[1]);
        awayScore = parseInt(scoreMatch[2]);
      }
      
      // Try to extract date
      if (text.match(/\d{1,2}\/\d{1,2}\/\d{4}/)) {
        date = text;
      }
    }
    
    if (!homeTeam || !awayTeam || !externalId) {
      return null;
    }
    
    return {
      homeTeam,
      awayTeam,
      homeScore,
      awayScore,
      date,
      externalId
    };
  }
}

module.exports = CslFixturesParser;
