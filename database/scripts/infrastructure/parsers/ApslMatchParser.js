const { JSDOM } = require('jsdom');

/**
 * APSL Match Schedule Parser
 * 
 * Parses match schedule tables from APSL team pages
 * HTML Structure: <h2>Match Schedule</h2> followed by <table>
 */
class ApslMatchParser {
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
    const opponentLink = matchCell.querySelector('a[href*="/APSL/Team/"]');
    
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
    
    // Cell 3 (optional): Result/Score
    let homeScore = null;
    let awayScore = null;
    let result = null;
    
    if (cells.length > 3) {
      const resultText = cells[3].textContent.trim();
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
    
    // Extract external match ID from view link
    const viewLink = matchCell.querySelector('a[href*="/APSL/Event/"]');
    let externalId = null;
    if (viewLink) {
      const href = viewLink.getAttribute('href');
      const match = href.match(/\/Event\/(\d+)/);
      if (match) {
        externalId = match[1];
      }
    }
    
    return {
      externalId,
      matchDate: date,
      matchTime: time,
      homeTeamId: isHomeMatch ? teamId : opponentId,
      awayTeamId: isHomeMatch ? opponentId : teamId,
      homeScore,
      awayScore,
      matchStatusId: matchStatus,
      matchType,
      venue: {
        name: locationText,
        address: venueAddress
      },
      opponentName,
      result,
      description: matchType
    };
  }
  
  /**
   * Parse date/time string like "Sunday, Sep 21 - 5:00 PM"
   */
  parseDateTimeString(text) {
    const dateMatch = text.match(/([A-Za-z]+,?\s+)?([A-Za-z]+)\s+(\d{1,2})(?:\s*-\s*(\d{1,2}):(\d{2})\s*(AM|PM))?/);
    
    if (!dateMatch) {
      return { date: null, time: null };
    }
    
    const monthName = dateMatch[2];
    const day = parseInt(dateMatch[3]);
    let hour = dateMatch[4] ? parseInt(dateMatch[4]) : null;
    const minute = dateMatch[5] ? dateMatch[5] : null;
    const period = dateMatch[6];
    
    // Convert month name to number
    const monthMap = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    const month = monthMap[monthName];
    
    if (!month) {
      return { date: null, time: null };
    }
    
    // Determine year (current or next year based on month)
    const now = new Date();
    const currentMonth = now.getMonth() + 1;
    let year = now.getFullYear();
    
    // If the month is before current month, assume next year
    if (month < currentMonth - 6) {
      year++;
    } else if (month > currentMonth + 6) {
      year--;
    }
    
    const date = `${year}-${String(month).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    
    let time = null;
    if (hour !== null && minute !== null) {
      // Convert to 24-hour format
      if (period === 'PM' && hour !== 12) {
        hour += 12;
      } else if (period === 'AM' && hour === 12) {
        hour = 0;
      }
      time = `${String(hour).padStart(2, '0')}:${minute}:00`;
    }
    
    return { date, time };
  }
  
  /**
   * Extract venue address from Google Maps link
   */
  extractVenueAddress(cell) {
    const mapLink = cell.querySelector('a[href*="maps.google.com"]');
    if (!mapLink) return null;
    
    const href = mapLink.getAttribute('href');
    const match = href.match(/\?q=([^&]+)/);
    if (match) {
      return decodeURIComponent(match[1].replace(/\+/g, ' '));
    }
    
    return null;
  }
  
  /**
   * Extract match type from text (Regular Season, Playoffs, etc.)
   */
  extractMatchType(text) {
    if (text.includes('Regular Season')) return 'Regular Season';
    if (text.includes('Playoff')) return 'Playoffs';
    if (text.includes('Final')) return 'Final';
    if (text.includes('Semifinal')) return 'Semifinals';
    if (text.includes('Quarterfinal')) return 'Quarterfinals';
    return 'Regular Season'; // Default
  }
  
  /**
   * Determine match status
   * 1 = scheduled, 2 = completed, 3 = cancelled, 4 = postponed
   */
  determineMatchStatus(date, time, homeScore, awayScore) {
    // If scores exist, it's completed
    if (homeScore !== null && awayScore !== null) {
      return 2;
    }
    
    // If date is in the past, assume completed
    if (date) {
      const matchDate = new Date(date);
      if (time) {
        const [hours, minutes] = time.split(':');
        matchDate.setHours(parseInt(hours), parseInt(minutes));
      }
      
      if (matchDate < new Date()) {
        return 2; // completed
      }
    }
    
    return 1; // scheduled
  }
}

module.exports = ApslMatchParser;
