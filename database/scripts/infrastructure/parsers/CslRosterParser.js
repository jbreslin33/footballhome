const { JSDOM } = require('jsdom');

/**
 * Parser for Cosmopolitan Soccer League team roster pages
 * Extracts player information from team pages
 */
class CslRosterParser {
  /**
   * Parse roster HTML to extract player list
   * @param {string} html - Raw HTML from team roster page
   * @returns {Array<{name: string, number: string}>} Array of players
   */
  parse(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    const players = [];
    
    // Find the roster table - typically has headers like "Player", "Position", etc.
    const tables = document.querySelectorAll('table');
    
    for (const table of tables) {
      // Check if this looks like a roster table
      const headers = table.querySelectorAll('th');
      let hasPlayerColumn = false;
      
      for (const header of headers) {
        if (header.textContent.toLowerCase().includes('player')) {
          hasPlayerColumn = true;
          break;
        }
      }
      
      if (!hasPlayerColumn) continue;
      
      // Parse rows
      const rows = table.querySelectorAll('tbody tr');
      for (const row of rows) {
        const cells = row.querySelectorAll('td');
        if (cells.length === 0) continue;
        
        // First cell typically contains player name
        const playerName = this.cleanPlayerName(cells[0].textContent.trim());
        if (!playerName) continue;
        
        // Try to extract jersey number if present
        const number = this.extractJerseyNumber(cells[0].textContent);
        
        players.push({
          name: playerName,
          number: number || null
        });
      }
    }
    
    return players;
  }
  
  /**
   * Clean player name from text
   * Removes jersey numbers, suspension notes, etc.
   * @param {string} text - Raw player text
   * @returns {string} Cleaned player name
   */
  cleanPlayerName(text) {
    // Remove jersey number at start (e.g., "23 Smith, John")
    let cleaned = text.replace(/^\d+\s+/, '');
    
    // Remove suspension text
    cleaned = cleaned.replace(/Suspended until \d{2}\/\d{2}\/\d{4}/gi, '').trim();
    
    // Remove extra whitespace
    cleaned = cleaned.replace(/\s+/g, ' ').trim();
    
    return cleaned;
  }
  
  /**
   * Extract jersey number from player text
   * @param {string} text - Raw player text
   * @returns {string|null} Jersey number or null
   */
  extractJerseyNumber(text) {
    const match = text.match(/^(\d+)\s+/);
    return match ? match[1] : null;
  }
}

module.exports = CslRosterParser;
