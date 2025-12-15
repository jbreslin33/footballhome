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
    const structure = {
      conferences: [],
      divisions: []
    };

    // APSL-specific: Find conference sections
    const conferenceSections = this.querySelectorAll('.conference-section');
    
    conferenceSections.forEach(section => {
      const conferenceName = this.cleanText(
        section.querySelector('.conference-title')?.textContent || ''
      );
      
      if (conferenceName) {
        structure.conferences.push({ name: conferenceName });
        
        // Find divisions within this conference
        const divisionTables = section.querySelectorAll('.standings-table');
        divisionTables.forEach(table => {
          const divisionName = this.cleanText(
            table.querySelector('.division-title')?.textContent || ''
          );
          
          if (divisionName) {
            structure.divisions.push({
              name: divisionName,
              conference: conferenceName
            });
          }
        });
      }
    });

    return structure;
  }

  /**
   * Parse team roster page
   */
  parseRoster() {
    const players = [];
    const rows = this.querySelectorAll('table.roster-table tbody tr');

    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 3) continue;

      const jersey = cells[0]?.textContent.trim();
      const name = cells[1]?.textContent.trim();
      const position = cells[2]?.textContent.trim();

      if (name) {
        players.push({
          jersey_number: jersey || null,
          name: name,
          position: position || null
        });
      }
    }

    return players;
  }

  /**
   * Parse schedule/fixtures page
   */
  parseSchedule() {
    const matches = [];
    const rows = this.querySelectorAll('table.schedule-table tbody tr');

    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 4) continue;

      const dateText = cells[0]?.textContent.trim();
      const opponent = cells[1]?.textContent.trim();
      const location = cells[2]?.textContent.trim();
      const result = cells[3]?.textContent.trim();

      if (dateText && opponent) {
        matches.push({
          date: this.parseDate(dateText),
          opponent: opponent,
          location: location || null,
          result: result || null,
          isHome: location?.toLowerCase().includes('home')
        });
      }
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
