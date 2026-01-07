const { JSDOM } = require('jsdom');

/**
 * Parser for Cosmopolitan Soccer League match event pages
 * Extracts player statistics (goals, assists) from match pages
 * Format: Separate tables for home and away teams with aggregated stats
 */
class CslMatchEventParser {
  /**
   * Parse match event HTML to extract player statistics
   * @param {string} html - Raw HTML from match event page
   * @param {string} homeTeamName - Expected home team name
   * @param {string} awayTeamName - Expected away team name
   * @returns {{homeTeam: Array, awayTeam: Array}} Player stats for both teams
   */
  parse(html, homeTeamName, awayTeamName) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    const result = {
      homeTeam: [],
      awayTeam: []
    };
    
    // Find all h2 headers that indicate team sections
    const headers = document.querySelectorAll('h2');
    
    for (const header of headers) {
      const teamName = header.textContent.trim();
      
      // Find the table that follows this header
      let table = header.nextElementSibling;
      while (table && table.tagName !== 'TABLE') {
        table = table.nextElementSibling;
      }
      
      if (!table) continue;
      
      const playerStats = this.parsePlayerStatsTable(table);
      
      // Match team name to home/away
      if (this.teamsMatch(teamName, homeTeamName)) {
        result.homeTeam = playerStats;
      } else if (this.teamsMatch(teamName, awayTeamName)) {
        result.awayTeam = playerStats;
      }
    }
    
    return result;
  }
  
  /**
   * Parse player statistics from a team's stats table
   * Columns: Player (0), MP (1), G (2), A (3), OG (4), KS (5), KGA (6)
   * @param {Element} table - Table element
   * @returns {Array<{playerName: string, goals: number, assists: number}>}
   */
  parsePlayerStatsTable(table) {
    const playerStats = [];
    const rows = table.querySelectorAll('tbody tr');
    
    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 7) continue; // Skip invalid rows
      
      const playerName = this.parsePlayerName(cells[0].textContent.trim());
      const goals = parseInt(cells[2].textContent.trim()) || 0;
      const assists = parseInt(cells[3].textContent.trim()) || 0;
      
      // Only include players with goals or assists
      if (goals > 0 || assists > 0) {
        playerStats.push({
          playerName,
          goals,
          assists
        });
      }
    }
    
    return playerStats;
  }
  
  /**
   * Parse player name from cell text
   * Handles various formats and removes suspension notes
   * @param {string} text - Raw player name text
   * @returns {string} Cleaned player name
   */
  parsePlayerName(text) {
    // Remove suspension text like "Suspended until MM/DD/YYYY"
    let cleaned = text.replace(/Suspended until \d{2}\/\d{2}\/\d{4}/gi, '').trim();
    
    // Remove extra whitespace
    cleaned = cleaned.replace(/\s+/g, ' ').trim();
    
    return cleaned;
  }
  
  /**
   * Check if two team names match (handles minor variations)
   * @param {string} name1 - First team name
   * @param {string} name2 - Second team name
   * @returns {boolean} True if teams match
   */
  teamsMatch(name1, name2) {
    const normalized1 = name1.toLowerCase().trim();
    const normalized2 = name2.toLowerCase().trim();
    
    // Exact match
    if (normalized1 === normalized2) return true;
    
    // Partial match
    if (normalized1.includes(normalized2) || normalized2.includes(normalized1)) {
      return true;
    }
    
    return false;
  }
}

module.exports = CslMatchEventParser;
