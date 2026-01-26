const { JSDOM } = require('jsdom');

/**
 * Parser for APSL team roster pages
 * Extracts player list from TeamPass roster table
 */
class ApslRosterParser {
  /**
   * Parse roster HTML to extract player list
   * @param {string} html - Raw HTML from team roster page
   * @returns {Array} Array of player objects with name
   */
  parseRoster(html) {
    const players = [];
    
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    // Find the "Team Roster" table
    const rosterTable = document.querySelector('table.TableRoster');
    
    if (!rosterTable) {
      return players; // No roster table found
    }
    
    // Get all rows (skip header row)
    const rows = Array.from(rosterTable.querySelectorAll('tr.TableRow0, tr.TableRow1'));
    
    for (const row of rows) {
      try {
        // Player name is in second <td>, inside a div
        const cells = row.querySelectorAll('td');
        if (cells.length < 2) continue;
        
        const nameCell = cells[1];
        const nameDiv = nameCell.querySelector('div');
        if (!nameDiv) continue;
        
        const fullName = nameDiv.textContent.trim();
        if (!fullName || fullName === '') continue;
        
        // Parse name (format: "FirstName LastName" or "FirstName MiddleName LastName")
        const nameParts = fullName.split(/\s+/).filter(p => p.length > 0);
        if (nameParts.length < 2) continue; // Need at least first + last name
        
        const firstName = nameParts[0];
        const lastName = nameParts[nameParts.length - 1];
        
        // Get added date if present (format: "added: MM/DD/YY")
        let addedDate = null;
        const addedText = nameCell.textContent.match(/added:\s*(\d{1,2}\/\d{1,2}\/\d{2})/);
        if (addedText) {
          // Convert MM/DD/YY to YYYY-MM-DD
          const [month, day, year] = addedText[1].split('/');
          const fullYear = parseInt(year) + 2000; // Assume 20xx
          addedDate = `${fullYear}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
        }
        
        // Get stats if present (Goals, Assists columns)
        let goals = null;
        let assists = null;
        if (cells.length >= 4) {
          const goalsText = cells[2].textContent.trim();
          const assistsText = cells[3].textContent.trim();
          if (goalsText && goalsText !== '') goals = parseInt(goalsText) || 0;
          if (assistsText && assistsText !== '') assists = parseInt(assistsText) || 0;
        }
        
        players.push({
          firstName,
          lastName,
          fullName,
          addedDate,
          stats: { goals, assists }
        });
      } catch (error) {
        console.warn('Error parsing player row:', error.message);
        continue;
      }
    }
    
    return players;
  }
  
  /**
   * Extract team ID from APSL team URL or filename
   * @param {string} urlOrFilename - URL or filename like "114812-bc27d2da.html"
   * @returns {string|null} Team ID (e.g., "114812")
   */
  extractTeamId(urlOrFilename) {
    const match = urlOrFilename.match(/(\d{6})/);
    return match ? match[1] : null;
  }
}

module.exports = ApslRosterParser;
