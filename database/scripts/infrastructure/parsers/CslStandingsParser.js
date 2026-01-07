const { JSDOM } = require('jsdom');

/**
 * Parser for Cosmopolitan Soccer League standings pages
 * Extracts divisions and teams from the standings table
 */
class CslStandingsParser {
  /**
   * Parse standings page HTML to extract divisions and teams
   * @param {string} html - Raw HTML from standings page
   * @returns {Array<{divisionName: string, teams: Array}>} Parsed divisions with teams
   */
  parse(html) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    const divisions = [];
    
    // Find all div elements that contain division names
    // Pattern: <div>2025/2026 - Division 1</div>
    const allDivs = document.querySelectorAll('div');
    
    for (const div of allDivs) {
      const text = div.textContent.trim();
      
      // Match division headers like "2025/2026 - Division 1" or "2025/2026 - Division 1 Reserve"
      const divisionMatch = text.match(/^(\d{4}\/\d{4})\s*-\s*(.+)$/);
      if (!divisionMatch) continue;
      
      const divisionName = divisionMatch[2].trim();
      
      // Find the table that follows this div
      // Navigate through siblings to find the next table
      let current = div;
      let table = null;
      
      while (current && !table) {
        current = current.nextElementSibling;
        if (current && current.tagName === 'TABLE') {
          table = current;
        }
        // Also check within parent's next sibling for accordion-style layouts
        if (!current && div.parentElement) {
          current = div.parentElement.nextElementSibling;
          if (current) {
            table = current.querySelector('table');
          }
        }
      }
      
      if (!table) continue;
      
      const teams = this.parseTeamsFromTable(table);
      
      // Only add if we found teams
      if (teams.length > 0) {
        divisions.push({
          divisionName,
          teams
        });
      }
    }
    
    return divisions;
  }
  
  /**
   * Parse teams from a standings table
   * @param {Element} table - Table element
   * @returns {Array<{rank: number, name: string, played: number, wins: number, draws: number, losses: number, goalsFor: number, goalsAgainst: number, goalDiff: number, points: number}>}
   */
  parseTeamsFromTable(table) {
    const teams = [];
    const rows = table.querySelectorAll('tbody tr');
    
    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 10) continue; // Skip header rows
      
      const teamName = cells[1].textContent.trim();
      
      // Skip empty rows or teams with no matches
      if (!teamName || cells[2].textContent.trim() === '0') continue;
      
      teams.push({
        rank: parseInt(cells[0].textContent.trim()) || 0,
        name: teamName,
        played: parseInt(cells[2].textContent.trim()) || 0,
        wins: parseInt(cells[3].textContent.trim()) || 0,
        draws: parseInt(cells[4].textContent.trim()) || 0,
        losses: parseInt(cells[5].textContent.trim()) || 0,
        goalsFor: parseInt(cells[6].textContent.trim()) || 0,
        goalsAgainst: parseInt(cells[7].textContent.trim()) || 0,
        goalDiff: parseInt(cells[8].textContent.trim()) || 0,
        points: parseInt(cells[9].textContent.trim()) || 0
      });
    }
    
    return teams;
  }
}

module.exports = CslStandingsParser;
