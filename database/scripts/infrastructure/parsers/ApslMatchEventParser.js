const { JSDOM } = require('jsdom');

/**
 * APSL Match Event Parser
 * 
 * Parses match events from APSL match event pages.
 * HTML Structure: 5-column table with headers: Team A | Play | Time | Play | Team B
 * Rows alternate showing events for either team.
 */
class ApslMatchEventParser {
  constructor() {}
  
  /**
   * Parse events from match event HTML
   * @param {string} html - Full HTML content of match event page
   * @param {string} homeTeamName - Home team name (from match record)
   * @param {string} awayTeamName - Away team name (from match record)
   * @returns {Array} Array of event objects: { playerName, eventType, minute, teamName, assistedByPlayerName }
   */
  parse(html, homeTeamName, awayTeamName) {
    const dom = new JSDOM(html);
    const document = dom.window.document;
    
    const events = [];
    
    // Find the events table - it has headers: Team Name | Play | Time | Play | Team Name
    const tables = document.querySelectorAll('table');
    
    for (const table of tables) {
      const headerRow = table.querySelector('tr');
      if (!headerRow) continue;
      
      const headers = Array.from(headerRow.querySelectorAll('th')).map(th => th.textContent.trim());
      
      // Look for table with "Play" and "Time" headers
      if (headers.includes('Play') && headers.includes('Time')) {
        // This is the events table
        const teamAName = headers[0]; // First column is Team A name
        const teamBName = headers[4]; // Last column is Team B name
        
        // Parse all event rows
        const rows = Array.from(table.querySelectorAll('tr')).slice(1); // Skip header row
        
        for (const row of rows) {
          const cells = Array.from(row.querySelectorAll('td'));
          if (cells.length !== 5) continue;
          
          const event = this.parseEventRow(cells, teamAName, teamBName);
          if (event) {
            events.push(event);
          }
        }
      }
    }
    
    return events;
  }
  
  /**
   * Parse a single event row
   * @param {Array} cells - Array of 5 td elements
   * @param {string} teamAName - Name of team in column 0
   * @param {string} teamBName - Name of team in column 4
   * @returns {Object|null} Event object or null if empty row
   */
  parseEventRow(cells, teamAName, teamBName) {
    // Column 0: Team A player name
    // Column 1: Team A event type (may contain soccer ball icon for goals)
    // Column 2: Time/minute
    // Column 3: Team B event type (may contain soccer ball icon for goals)
    // Column 4: Team B player name
    
    const teamAPlayer = cells[0].textContent.trim();
    const teamAEventCell = cells[1];
    const minute = cells[2].textContent.trim();
    const teamBEventCell = cells[3];
    const teamBPlayer = cells[4].textContent.trim();
    
    // Check for soccer ball icon (goal indicator) in Play columns
    const teamAHasGoal = this.hasSoccerBallIcon(teamAEventCell);
    const teamBHasGoal = this.hasSoccerBallIcon(teamBEventCell);
    
    // Get text-based event types (for other events like cards, subs)
    const teamAEventText = teamAEventCell.textContent.trim();
    const teamBEventText = teamBEventCell.textContent.trim();
    
    // Determine which side has the event
    let playerName = null;
    let eventType = null;
    let teamName = null;
    
    if (teamAPlayer && (teamAHasGoal || teamAEventText)) {
      playerName = this.parsePlayerName(teamAPlayer);
      eventType = teamAHasGoal ? 'goal' : this.normalizeEventType(teamAEventText);
      teamName = teamAName;
    } else if (teamBPlayer && (teamBHasGoal || teamBEventText)) {
      playerName = this.parsePlayerName(teamBPlayer);
      eventType = teamBHasGoal ? 'goal' : this.normalizeEventType(teamBEventText);
      teamName = teamBName;
    }
    
    // Skip if no valid event found
    if (!playerName || !eventType) {
      return null;
    }
    
    // Parse minute (default to 0 if empty)
    const minuteInt = minute ? parseInt(minute, 10) : 0;
    if (isNaN(minuteInt)) {
      return null;
    }
    
    return {
      playerName,
      eventType,
      minute: minuteInt,
      teamName,
      assistedByPlayerName: null // We'll handle assists separately
    };
  }
  
  /**
   * Check if a cell contains a soccer ball icon (indicates a goal)
   * @param {Element} cell - The td element to check
   * @returns {boolean} True if soccer ball icon is present
   */
  hasSoccerBallIcon(cell) {
    // Check for img tag with soccer ball (common pattern)
    const img = cell.querySelector('img');
    if (img) {
      const src = img.getAttribute('src') || '';
      const alt = img.getAttribute('alt') || '';
      // Look for soccer ball indicators in src or alt text
      if (src.includes('ball') || src.includes('goal') || src.includes('soccer') ||
          alt.toLowerCase().includes('ball') || alt.toLowerCase().includes('goal')) {
        return true;
      }
    }
    
    // Check for soccer ball emoji or unicode character (⚽)
    const text = cell.textContent;
    if (text.includes('⚽') || text.includes('🥅')) {
      return true;
    }
    
    // Check for span/div with specific classes that might indicate a goal icon
    const iconElements = cell.querySelectorAll('[class*="ball"], [class*="goal"], [class*="icon"]');
    if (iconElements.length > 0) {
      for (const elem of iconElements) {
        const className = elem.className || '';
        if (className.includes('ball') || className.includes('goal')) {
          return true;
        }
      }
    }
    
    return false;
  }

  /**
   * Parse player name from cell text
   * Format: "LastName, FirstName" or just "Name"
   * @param {string} text - Raw player name text
   * @returns {string} Parsed player name
   */
  parsePlayerName(text) {
    return text.trim();
  }
  
  /**
   * Normalize event type from APSL format to our database format
   * @param {string} apslEventType - Event type from APSL (e.g., "Sub In", "Yellow Card")
   * @returns {string} Normalized event type matching match_event_types.name
   * NOTE: Goals are detected via soccer ball icons, not text
   */
  normalizeEventType(eventType) {
    const normalized = eventType.toLowerCase().trim();
    
    // Map APSL event types to our database event types
    // NOTE: Goals are shown as soccer ball icons in the HTML, not as text
    const eventMap = {
      'assist': 'assist',  // Actual assists
      'sub in': 'sub_in',
      'sub out': 'sub_out',
      'goal': 'goal',  // Just in case goals appear as text
      'yellow card': 'yellow_card',
      'red card': 'red_card',
      'shot on target': 'shot_on_target',
      'shot off target': 'shot_off_target',
      'save': 'save',
      'corner': 'corner',
      'foul': 'foul',
      'offside': 'offside',
      'penalty awarded': 'penalty_awarded',
      'penalty missed': 'penalty_missed',
      'own goal': 'own_goal',
      'injury': 'injury'
    };
    
    return eventMap[normalized] || null;
  }
}

module.exports = ApslMatchEventParser;
