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
    
    // Find "Team Roster" heading first (like APSL pattern with "Match Schedule")
    const rosterHeading = Array.from(document.querySelectorAll('h2')).find(h2 => 
      h2.textContent.includes('Team Roster')
    );
    
    if (!rosterHeading) {
      return players; // No roster section found
    }
    
    // Find the table that follows the "Team Roster" heading
    let table = rosterHeading.nextElementSibling;
    while (table && table.tagName !== 'TABLE') {
      table = table.nextElementSibling;
    }
    
    if (!table) {
      return players;
    }
    
    // Parse rows from the Team Roster table
    const rows = table.querySelectorAll('tbody tr');
    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 2) continue; // Need at least player name column
      
      // Column structure: [Photo, Player Name + Date, Goals, Assists]
      // Player name is in cell 1
      const playerText = cells[1].textContent.trim();
      const playerName = this.cleanPlayerName(playerText);
      if (!playerName) continue;
      
      // CSL format is "FirstName LastName", convert to "LastName, FirstName" for consistency
      const convertedName = this.convertNameFormat(playerName);
      
      players.push({
        name: convertedName,
        number: null // CSL roster doesn't show jersey numbers
      });
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
    
    // Remove "added: MM/DD/YY" date text
    cleaned = cleaned.replace(/added:\s*\d{1,2}\/\d{1,2}\/\d{2}/gi, '').trim();
    
    // Remove suspension text
    cleaned = cleaned.replace(/Suspended until \d{2}\/\d{2}\/\d{4}/gi, '').trim();
    
    // Remove extra whitespace
    cleaned = cleaned.replace(/\s+/g, ' ').trim();
    
    return cleaned;
  }
  
  /**
   * Convert "FirstName LastName" to "LastName, FirstName" for consistency
   * @param {string} name - Name in "FirstName LastName" format
   * @returns {string} Name in "LastName, FirstName" format
   */
  convertNameFormat(name) {
    const parts = name.trim().split(/\s+/);
    if (parts.length < 2) {
      return name; // Can't convert, return as-is
    }
    
    // First word is first name, rest is last name
    const firstName = parts[0];
    const lastName = parts.slice(1).join(' ');
    
    return `${lastName}, ${firstName}`;
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
