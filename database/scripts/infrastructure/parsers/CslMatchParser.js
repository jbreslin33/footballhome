const { JSDOM } = require('jsdom');

/**
 * CSL Match Schedule Parser
 * 
 * Parses match schedule tables from CSL team pages
 * HTML Structure: <h2>Match Schedule</h2> followed by <table>
 */
class CslMatchParser {
  constructor() {}
  
  /**
   * Parse matches from team page HTML
   * @param {string} html - Full HTML content of team page
   * @param {number} teamId - The team ID these matches belong to
   * @returns {Array} Array of match objects
   */
  parse(html, teamId) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    // Find "Match Schedule" heading
    const scheduleHeading = Array.from(document.querySelectorAll('h2')).find(h2 => 
      h2.textContent.includes('Match Schedule')
    );
    
    if (!scheduleHeading) {
      return [];
    }
    
    // Find the table following the heading
    let table = scheduleHeading.nextElementSibling;
    while (table && table.tagName !== 'TABLE') {
      table = table.nextElementSibling;
    }
    
    if (!table) {
      return [];
    }
    
    const matches = [];
    const rows = table.querySelectorAll('tbody tr');
    
    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 3) continue; // Skip invalid rows
      
      try {
        const match = this.parseMatchRow(cells, teamId);
        if (match) {
          matches.push(match);
        }
      } catch (error) {
        console.error('Error parsing match row:', error.message);
        continue;
      }
    }
    
    return matches;
  }
  
  /**
   * Parse a single match row
   * @param {NodeList} cells - Table cells for this match
   * @param {number} teamId - The team ID
   * @returns {Object|null} Match data object or null if invalid
   */
  parseMatchRow(cells, teamId) {
    if (cells.length < 3) return null;
    
    // Cell 0: Date & Time
    const dateTimeText = cells[0].textContent.trim();
    const { date, time } = this.parseDateTimeString(dateTimeText);
    
    // Cell 1: Location/Venue
    const locationText = cells[1].textContent.trim();
    const venueAddress = this.extractVenueAddress(cells[1]);
    
    // Cell 2: Match details (opponent, home/away)
    const matchCell = cells[2];
    const isHomeMatch = matchCell.textContent.toLowerCase().includes('vs');
    const opponentLink = matchCell.querySelector('a[href*="/CSL/Team/"]');
    
    let opponentId = null;
    let opponentName = null;
    
    if (opponentLink) {
      const href = opponentLink.getAttribute('href');
      const match = href.match(/\/Team\/(\d+)/);
      if (match) {
        opponentId = parseInt(match[1]);
      }
      opponentName = opponentLink.textContent.trim();
    }
    
    // Extract match type from description
    const matchType = this.extractMatchType(matchCell.textContent);
    
    // Cell 3 (optional): Result/Score and Event Link
    let homeScore = null;
    let awayScore = null;
    let result = null;
    let externalId = null;
    
    if (cells.length > 3) {
      const resultCell = cells[3];
      const resultText = resultCell.textContent.trim();
      
      // Extract external ID from event link in result cell
      const eventLink = resultCell.querySelector('a[href*="/CSL/Event/"]');
      if (eventLink) {
        const href = eventLink.getAttribute('href');
        const match = href.match(/\/Event\/([^'"]+)/);
        if (match) {
          externalId = match[1];
        }
      }
      const scoreMatch = resultText.match(/\((\d+)\s*-\s*(\d+)\)/);
      if (scoreMatch) {
        if (isHomeMatch) {
          homeScore = parseInt(scoreMatch[1]);
          awayScore = parseInt(scoreMatch[2]);
        } else {
          awayScore = parseInt(scoreMatch[1]);
          homeScore = parseInt(scoreMatch[2]);
        }
      }
      result = resultText.match(/(Win|Loss|Draw)/i)?.[1] || null;
    }
    
    // Determine status
    const matchStatus = this.determineMatchStatus(date, time, homeScore, awayScore);
    
    // Return match object with team IDs based on home/away
    return {
      homeTeamId: isHomeMatch ? teamId : opponentId,
      awayTeamId: isHomeMatch ? opponentId : teamId,
      matchDate: date,
      matchTime: time,
      homeScore: homeScore,
      awayScore: awayScore,
      matchStatusId: matchStatus,
      description: matchType || locationText,
      venueAddress: venueAddress,
      externalId: externalId,
      isHome: isHomeMatch,
      opponentId: opponentId,
      opponentName: opponentName
    };
  }
  
  /**
   * Parse date/time string
   * @param {string} dateTimeText - Raw date/time text
   * @returns {Object} { date: 'YYYY-MM-DD', time: 'HH:MM:SS' }
   */
  parseDateTimeString(dateTimeText) {
    // CSL format examples: 
    // "Sunday, Sep 07 - 2:00 PM"
    // "Monday, Oct 14 - 10:00 AM"
    // Note: No year provided, must infer
    
    // Extract month and day
    const dateMatch = dateTimeText.match(/(Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s+(\d{1,2})/i);
    const timeMatch = dateTimeText.match(/(\d{1,2}):(\d{2})\s*(AM|PM)?/i);
    
    let date = null;
    let time = null;
    
    if (dateMatch) {
      const [, monthStr, day] = dateMatch;
      
      // Map month names to numbers
      const monthMap = {
        'Jan': '01', 'Feb': '02', 'Mar': '03', 'Apr': '04',
        'May': '05', 'Jun': '06', 'Jul': '07', 'Aug': '08',
        'Sep': '09', 'Oct': '10', 'Nov': '11', 'Dec': '12'
      };
      
      const month = monthMap[monthStr];
      
      // Infer year: assume current season (typically Sep-May)
      // If month is Jan-May, use current year
      // If month is Jun-Dec, check if we're past June; if so use current year, else use next year
      const now = new Date();
      const currentYear = now.getFullYear();
      const currentMonth = now.getMonth() + 1; // 1-12
      
      let year = currentYear;
      const matchMonth = parseInt(month);
      
      // CSL season typically runs Sep-May
      // If match is Sep-Dec and we're currently in Jan-Aug, match was previous year
      // If match is Jan-May and we're currently in Sep-Dec, match is next year
      if (matchMonth >= 9 && currentMonth < 9) {
        year = currentYear - 1; // Match was last fall
      } else if (matchMonth <= 5 && currentMonth >= 9) {
        year = currentYear + 1; // Match is next spring
      }
      
      date = `${year}-${month}-${day.padStart(2, '0')}`;
    }
    
    if (timeMatch) {
      let [, hours, minutes, meridiem] = timeMatch;
      hours = parseInt(hours);
      
      if (meridiem) {
        if (meridiem.toUpperCase() === 'PM' && hours !== 12) {
          hours += 12;
        } else if (meridiem.toUpperCase() === 'AM' && hours === 12) {
          hours = 0;
        }
      }
      
      time = `${hours.toString().padStart(2, '0')}:${minutes}:00`;
    }
    
    return { date, time };
  }
  
  /**
   * Extract venue address from cell
   * @param {Element} cell - Table cell element
   * @returns {string|null} Venue address
   */
  extractVenueAddress(cell) {
    const text = cell.textContent.trim();
    // Look for address patterns (city, state zip)
    const addressMatch = text.match(/([A-Za-z\s]+),\s*([A-Z]{2})\s*(\d{5})/);
    return addressMatch ? addressMatch[0] : null;
  }
  
  /**
   * Extract match type from text
   * @param {string} text - Cell text content
   * @returns {string|null} Match type (e.g., "Regular Season", "Playoff")
   */
  extractMatchType(text) {
    if (text.includes('Regular Season')) return 'Regular Season';
    if (text.includes('Playoff')) return 'Playoff';
    if (text.includes('Cup')) return 'Cup';
    if (text.includes('Friendly')) return 'Friendly';
    return null;
  }
  
  /**
   * Determine match status based on date and scores
   * @param {string} date - Match date (YYYY-MM-DD)
   * @param {string} time - Match time (HH:MM:SS)
   * @param {number} homeScore - Home team score
   * @param {number} awayScore - Away team score
   * @returns {number} Match status ID (1=scheduled, 2=in-progress, 3=completed, 4=postponed, 5=cancelled)
   */
  determineMatchStatus(date, time, homeScore, awayScore) {
    // If scores exist, match is completed
    if (homeScore !== null && awayScore !== null) {
      return 3; // completed
    }
    
    // If no date, assume scheduled
    if (!date) {
      return 1; // scheduled
    }
    
    // Check if match date has passed
    const matchDateTime = new Date(`${date}T${time || '00:00:00'}`);
    const now = new Date();
    
    if (matchDateTime < now) {
      // Past match without score - might be postponed
      return 4; // postponed
    }
    
    return 1; // scheduled
  }
}

module.exports = CslMatchParser;
