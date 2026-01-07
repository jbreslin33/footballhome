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
    // Column 1: Team A event type (icon: <i class="fa-solid fa-futbol"></i> for goals, or text)
    // Column 2: Time/minute
    // Column 3: Team B event type (icon: <i class="fa-solid fa-futbol"></i> for goals, or text)
    // Column 4: Team B player name
    
    const teamAPlayer = cells[0].textContent.trim();
    const teamAEventCell = cells[1];
    const minute = cells[2].textContent.trim();
    const teamBEventCell = cells[3];
    const teamBPlayer = cells[4].textContent.trim();
    
    // Check for goal icon (Font Awesome soccer ball)
    const teamAHasGoalIcon = this.hasGoalIcon(teamAEventCell);
    const teamBHasGoalIcon = this.hasGoalIcon(teamBEventCell);
    
    // Get text-based event types
    const teamAEventText = teamAEventCell.textContent.trim();
    const teamBEventText = teamBEventCell.textContent.trim();
    
    // Determine which side has the event
    let playerName = null;
    let eventType = null;
    let teamName = null;
    
    if (teamAPlayer && (teamAHasGoalIcon || teamAEventText)) {
      playerName = this.parsePlayerName(teamAPlayer);
      eventType = teamAHasGoalIcon ? 'goal' : this.normalizeEventType(teamAEventText);
      teamName = teamAName;
    } else if (teamBPlayer && (teamBHasGoalIcon || teamBEventText)) {
      playerName = this.parsePlayerName(teamBPlayer);
      eventType = teamBHasGoalIcon ? 'goal' : this.normalizeEventType(teamBEventText);
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
   * Check if cell contains a Font Awesome soccer ball icon (goal indicator)
   * @param {Element} cell - The td element to check
   * @returns {boolean} True if soccer ball icon present
   */
  hasGoalIcon(cell) {
    // Check for Font Awesome icon: <i class="fa-solid fa-futbol"></i>
    const icon = cell.querySelector('i.fa-futbol');
    if (icon) {
      return true;
    }
    
    // Also check for variations
    const icons = cell.querySelectorAll('i[class*="futbol"], i[class*="soccer"], i[class*="ball"]');
    return icons.length > 0;
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
   * @param {string} apslEventType - Event type from APSL (e.g., "Sub In", "Assist")
   * @returns {string} Normalized event type matching match_event_types.name
   * NOTE: APSL uses "Assist" text for goals (displays as soccer ball icon on website)
   */
  normalizeEventType(eventType) {
    const normalized = eventType.toLowerCase().trim();
    
    // Map APSL event types to our database event types
    // CRITICAL: APSL HTML contains "Assist" text which displays as soccer ball icon
    const eventMap = {
      'assist': 'goal',  // APSL uses "Assist" text for goals (renders as ball icon on site)
      'sub in': 'sub_in',
      'sub out': 'sub_out',
      'goal': 'goal',  // Just in case
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
