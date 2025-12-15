const HtmlParser = require('./HtmlParser');

/**
 * APSL-specific HTML Parser
 * Knows how to parse APSL website structure
 */
class ApslHtmlParser extends HtmlParser {
  /**
   * Parse standings page to extract conferences and divisions
   */
  parseStandingsStructure() {
    const conferenceData = [];
    
    // APSL format: Divs with text like "2025/2026 - Conference Name"
    const allDivs = this.querySelectorAll('div');
    
    for (const div of allDivs) {
      const text = div.textContent.trim();
      
      // Look for "2025/2026 - Conference Name" pattern
      const confMatch = text.match(/^(\d{4}\/\d{4})\s*-\s*(.+?)\s+Conference\s*$/);
      
      if (confMatch) {
        const season = confMatch[1];
        const confName = confMatch[2].trim() + ' Conference';
        
        // Find the standings table following this div
        // It's usually in the next sibling element
        let currentElement = div.parentElement;
        let table = null;
        
        // Look for table in next few siblings
        let attempts = 0;
        while (currentElement && !table && attempts < 5) {
          currentElement = currentElement.nextElementSibling;
          if (currentElement) {
            table = currentElement.querySelector('table');
          }
          attempts++;
        }
        
        if (table) {
          conferenceData.push({
            name: confName,
            season: season,
            table: table
          });
        }
      }
    }
    
    return conferenceData;
  }

  /**
   * Parse team roster page
   */
  parseRoster() {
    const players = [];
    
    // APSL uses table.TableRoster for rosters
    const rosterTables = this.querySelectorAll('table.TableRoster');
    let allPlayerRows = [];
    
    // Try main roster table
    for (const table of rosterTables) {
      const rows = Array.from(table.querySelectorAll('tr'));
      allPlayerRows = allPlayerRows.concat(rows.filter(r => r.textContent.includes('added:')));
    }
    
    // Fallback: search all tables for roster data
    if (allPlayerRows.length === 0) {
      const allTables = this.querySelectorAll('table');
      for (const table of allTables) {
        if (table.textContent.includes('added:')) {
          const rows = Array.from(table.querySelectorAll('tr'));
          allPlayerRows = rows.filter(r => r.textContent.includes('added:'));
          break;
        }
      }
    }
    
    // Parse each player row
    for (const row of allPlayerRows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 2) continue;

      // APSL roster structure:
      // Cell 0: Photo
      // Cell 1: Player name in a div + "added:" date
      // Cell 2: Jersey number
      
      // Extract player photo
      const photoImg = cells[0]?.querySelector('img');
      let photoUrl = null;
      if (photoImg) {
        const src = photoImg.getAttribute('src');
        if (src && src.includes('/mediacontent/')) {
          photoUrl = src.startsWith('http') ? src : 'https://app.teampass.com' + src;
        }
      }
      
      // Get player name from div with specific styling
      const nameDiv = cells[1]?.querySelector('div[style*="font-size:12px"]');
      const playerName = nameDiv?.textContent.trim();
      
      // Get jersey number
      const jerseyNum = cells[2]?.textContent.trim() || null;
      
      if (!playerName || playerName.toLowerCase() === 'player') continue;

      players.push({
        name: playerName,
        jersey_number: jerseyNum,
        position: null, // APSL doesn't provide positions
        photo_url: photoUrl
      });
    }

    return players;
  }

  /**
   * Parse schedule/fixtures page
   */
  parseSchedule() {
    const matches = [];
    
    // Find the Match Schedule table (has "Date & Time" header)
    const tables = this.querySelectorAll('table.Table');
    let scheduleTable = null;
    
    for (const table of tables) {
      const header = table.querySelector('th');
      if (header?.textContent.includes('Date & Time')) {
        scheduleTable = table;
        break;
      }
    }
    
    if (!scheduleTable) {
      return matches;
    }
    
    // Process each row
    const rows = scheduleTable.querySelectorAll('tr.TableRow0, tr.TableRow1');
    
    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 3) continue;
      
      // Cell 0: Date & Time (e.g., "Sunday, Sep 07 - 4:30 PM")
      // Cell 1: Opponent
      // Cell 2: Location/Venue
      
      const dateText = cells[0]?.textContent.trim();
      const opponent = cells[1]?.textContent.trim();
      const location = cells[2]?.textContent.trim();
      
      if (!dateText || !opponent) continue;
      
      // Determine if home or away
      const isHome = location?.toLowerCase().includes('home') || 
                     !location?.toLowerCase().includes('@');

      matches.push({
        date: this.parseDate(dateText),
        opponent: opponent,
        location: location || null,
        result: null,
        isHome: isHome
      });
    }

    return matches;
  }

  /**
   * Parse date from APSL format
   */
  parseDate(dateText) {
    // APSL format: "Sunday, Sep 07 - 4:30 PM"
    const dateMatch = dateText.match(/(\w+),\s*(\w+)\s+(\d+)/);
    const timeMatch = dateText.match(/(\d{1,2}:\d{2})\s*(AM|PM)/i);

    if (!dateMatch) return null;

    const monthName = dateMatch[2];
    const day = parseInt(dateMatch[3]);
    const months = { 
      Jan: 0, Feb: 1, Mar: 2, Apr: 3, May: 4, Jun: 5,
      Jul: 6, Aug: 7, Sep: 8, Oct: 9, Nov: 10, Dec: 11 
    };
    const month = months[monthName];

    // Determine year: Sep-Dec = current year, Jan-May = next year
    const year = month >= 8 ? 2025 : 2026;

    const date = new Date(year, month, day);

    // Add time if available
    if (timeMatch) {
      let hours = parseInt(timeMatch[1].split(':')[0]);
      const minutes = parseInt(timeMatch[1].split(':')[1]);
      const isPM = timeMatch[2].toUpperCase() === 'PM';

      if (isPM && hours < 12) hours += 12;
      if (!isPM && hours === 12) hours = 0;

      date.setHours(hours, minutes, 0, 0);
    }

    return date.toISOString();
  }

  /**
   * Extract team links from division page
   */
  parseTeamLinks() {
    const teams = [];
    const links = this.getLinks('a', '/APSL/Team/');

    for (const link of links) {
      const teamIdMatch = link.href.match(/\/Team\/(\d+)/);
      if (teamIdMatch) {
        teams.push({
          name: link.text,
          apsl_team_id: teamIdMatch[1],
          url: link.href
        });
      }
    }

    return teams;
  }

  /**
   * Split player name into first/last
   */
  static splitName(fullName) {
    const parts = fullName.trim().split(/\s+/);
    if (parts.length === 0) return { first: '', last: '' };
    if (parts.length === 1) return { first: parts[0], last: '' };
    
    const last = parts.pop();
    const first = parts.join(' ');
    
    return { first, last };
  }
}

module.exports = ApslHtmlParser;
