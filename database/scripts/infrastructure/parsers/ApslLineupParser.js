const { JSDOM } = require('jsdom');

/**
 * APSL Match Lineup Parser
 * 
 * Parses starter and substitute lineups from APSL match event pages.
 * HTML Structure: Tables with "Starter" and "Substitute" headers followed by team names
 */
class ApslLineupParser {
  constructor() {}
  
  /**
   * Parse lineups from match event HTML
   * @param {string} html - Full HTML content of match event page
   * @returns {Object} { starters: [], substitutes: [] }
   */
  parse(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    const lineups = {
      starters: [],
      substitutes: []
    };
    
    // Find all tables
    const tables = document.querySelectorAll('table');
    
    for (const table of tables) {
      // Check if this is a lineup table by looking for Starter/Substitute header
      const headerRow = table.querySelector('tr');
      if (!headerRow) continue;
      
      const firstHeader = headerRow.querySelector('th');
      if (!firstHeader) continue;
      
      const headerText = firstHeader.textContent.trim();
      
      if (headerText === 'Starter') {
        const players = this.parseLineupTable(table);
        lineups.starters.push(...players);
      } else if (headerText === 'Substitute') {
        const players = this.parseLineupTable(table);
        lineups.substitutes.push(...players);
      }
    }
    
    return lineups;
  }
  
  /**
   * Parse a single lineup table (Starter or Substitute)
   * Table structure:
   *   Row 1: Header (th: "Starter" or "Substitute")
   *   Row 2: Team names (th: Team 1, td: players list, th: Team 2, td: players list)
   *   
   * Players are listed in cells separated by <br> tags
   * 
   * @param {Element} table - The table element
   * @returns {Array} Array of player objects with { playerName, teamName, jerseyNumber }
   */
  parseLineupTable(table) {
    const players = [];
    const rows = table.querySelectorAll('tr');
    
    if (rows.length < 2) return players;
    
    // Row 2 has team names and player lists
    const dataRow = rows[1];
    const headers = dataRow.querySelectorAll('th');
    const cells = dataRow.querySelectorAll('td');
    
    // Process each team (alternating th/td pattern)
    for (let i = 0; i < headers.length; i++) {
      const teamName = headers[i]?.textContent.trim();
      const playerCell = cells[i];
      
      if (!teamName || !playerCell) continue;
      
      // Split by <br> tags to get individual players
      const playerNames = this.splitByBreaks(playerCell);
      
      for (const playerName of playerNames) {
        const player = this.parsePlayerCell(playerName, teamName);
        if (player) players.push(player);
      }
    }
    
    return players;
  }
  
  /**
   * Split cell content by <br> tags
   */
  splitByBreaks(cell) {
    const innerHTML = cell.innerHTML;
    // Split by <br> tags (various formats)
    const parts = innerHTML.split(/<br\s*\/?>/i);
    
    return parts
      .map(p => {
        // Strip HTML tags and clean up
        return p.replace(/<[^>]*>/g, '').trim();
      })
      .filter(p => {
        // Filter out empty, too long, or team names (which appear in headers)
        return p.length > 0 && 
               p.length < 100 && 
               !p.match(/^\d{4}$/) && // Not just a year
               !p.includes('FC') && 
               !p.includes('SC') &&
               !p.includes('United') &&
               !p.includes('Club');
      });
  }
  
  /**
   * Parse player cell text to extract name and jersey number
   * Format examples:
   *   "Smith, John"
   *   "Doe, Jane #7"
   *   "Johnson, Bob (#12)"
   * 
   * @param {string} text - Player cell text
   * @param {string} teamName - Team name
   * @returns {Object|null} { playerName, teamName, jerseyNumber }
   */
  parsePlayerCell(text, teamName) {
    if (!text || text.length === 0) return null;
    
    // Extract jersey number if present
    let jerseyNumber = null;
    let playerName = text;
    
    // Match patterns: #7, (#12), etc.
    const jerseyMatch = text.match(/[#(](\d+)\)?/);
    if (jerseyMatch) {
      jerseyNumber = parseInt(jerseyMatch[1], 10);
      // Remove jersey number from name
      playerName = text.replace(/[#(]\d+\)?/, '').trim();
    }
    
    // Clean up name (remove extra whitespace, newlines)
    playerName = playerName.replace(/\s+/g, ' ').trim();
    
    if (playerName.length === 0) return null;
    
    return {
      playerName,
      teamName,
      jerseyNumber
    };
  }
}

module.exports = ApslLineupParser;
