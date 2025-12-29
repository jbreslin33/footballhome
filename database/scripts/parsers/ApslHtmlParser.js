const HtmlParser = require('./HtmlParser');

/**
 * APSL-specific HTML Parser
 * Knows how to parse APSL website structure
 */
class ApslHtmlParser extends HtmlParser {

    /**
     * Parse per-match player stats from APSL match event page
     * Returns array of { name, teamName, goals, assists, yellow_cards, red_cards, is_starter, sub_in_minute, sub_out_minute, minutes_played }
     */
    parseMatchPlayerStats() {
      const playerStats = new Map(); // Use map to accumulate stats per player
      const playerTeams = new Map(); // Track which team each player belongs to
      
      // Step 1: Find "Starter" section and extract starting lineups
      const allText = this.document.body.textContent;
      const starterIndex = allText.indexOf('Starter');
      
      if (starterIndex === -1) return [];
      
      // Find tables after "Starter" label
      const tables = this.querySelectorAll('table');
      let starterTable = null;
      let substituteTable = null;
      let playByPlayTable = null;
      
      // Look for tables with team names as headers
      for (const table of tables) {
        const text = table.textContent;
        if (text.includes('Starter') || text.includes('Substitute')) {
          if (!starterTable && text.includes('Starter')) {
            starterTable = table;
          } else if (!substituteTable && text.includes('Substitute')) {
            substituteTable = table;
          }
        }
        // Play-by-play table has "Play" "Time" "Play" structure
        if (text.includes('Play') && text.includes('Time')) {
          playByPlayTable = table;
        }
      }
      
      // Parse starters
      if (starterTable) {
        const rows = starterTable.querySelectorAll('tr');
        for (const row of rows) {
          // Check if this row has a team name header
          const teamHeader = row.querySelector('th');
          let currentTeamName = null;
          if (teamHeader) {
            currentTeamName = teamHeader.textContent.trim();
          }
          
          const cells = row.querySelectorAll('td');
          for (const cell of cells) {
            // Player names are separated by <br> tags
            const html = cell.innerHTML;
            const playerNames = html.split('<br>')
              .map(name => name.replace(/<[^>]*>/g, '').trim())
              .filter(name => {
                // Filter out team names, headers, and short strings
                return name && 
                       name.length > 2 && 
                       name !== 'Starter' &&
                       !name.includes(' SC') && 
                       !name.includes(' FC') && 
                       !name.includes('Soccer Club') &&
                       !name.includes('United');
              });
            for (const playerName of playerNames) {
              if (!playerStats.has(playerName)) {
                playerStats.set(playerName, {
                  name: playerName,
                  goals: 0,
                  assists: 0,
                  yellow_cards: 0,
                  red_cards: 0,
                  is_starter: true,
                  sub_in_minute: null,
                  sub_out_minute: null,
                  minutes_played: 90 // Default for starters
                });
                if (currentTeamName) {
                  playerTeams.set(playerName, currentTeamName);
                }
              }
            }
          }
        }
      }
      
      // Parse substitutes
      if (substituteTable) {
        const rows = substituteTable.querySelectorAll('tr');
        for (const row of rows) {
          // Check if this row has a team name header
          const teamHeader = row.querySelector('th');
          let currentTeamName = null;
          if (teamHeader) {
            currentTeamName = teamHeader.textContent.trim();
          }
          
          const cells = row.querySelectorAll('td');
          for (const cell of cells) {
            // Player names are separated by <br> tags
            const html = cell.innerHTML;
            const playerNames = html.split('<br>')
              .map(name => name.replace(/<[^>]*>/g, '').trim())
              .filter(name => {
                // Filter out team names, headers, and short strings
                return name && 
                       name.length > 2 && 
                       name !== 'Substitute' &&
                       !name.includes(' SC') && 
                       !name.includes(' FC') && 
                       !name.includes('Soccer Club') &&
                       !name.includes('United');
              });
            for (const playerName of playerNames) {
              if (!playerStats.has(playerName)) {
                playerStats.set(playerName, {
                  name: playerName,
                  goals: 0,
                  assists: 0,
                  yellow_cards: 0,
                  red_cards: 0,
                  is_starter: false,
                  sub_in_minute: null,
                  sub_out_minute: null,
                  minutes_played: 0
                });
                if (currentTeamName) {
                  playerTeams.set(playerName, currentTeamName);
                }
              }
            }
          }
        }
      }
      
      // Parse play-by-play for goals, cards, and substitutions
      if (playByPlayTable) {
        const rows = playByPlayTable.querySelectorAll('tr');
        for (const row of rows) {
          const cells = Array.from(row.querySelectorAll('td'));
          if (cells.length >= 3) {
            const timeCell = cells[1]?.textContent.trim();
            const minute = parseInt(timeCell) || 0;
            
            // Check all cells for player actions
            for (const cell of cells) {
              const text = cell.textContent.trim();
              
              // Goal: "Player Name (Goal)"
              if (text.includes('Goal')) {
                const match = text.match(/^(.+?)\s*\(Goal\)/);
                if (match) {
                  const playerName = match[1].trim();
                  if (playerStats.has(playerName)) {
                    playerStats.get(playerName).goals++;
                  }
                }
              }
              
              // Yellow card: "Player Name (Yellow Card)"
              if (text.includes('Yellow Card')) {
                const match = text.match(/^(.+?)\s*\(Yellow Card\)/);
                if (match) {
                  const playerName = match[1].trim();
                  if (playerStats.has(playerName)) {
                    playerStats.get(playerName).yellow_cards++;
                  }
                }
              }
              
              // Red card: "Player Name (Red Card)"
              if (text.includes('Red Card')) {
                const match = text.match(/^(.+?)\s*\(Red Card\)/);
                if (match) {
                  const playerName = match[1].trim();
                  if (playerStats.has(playerName)) {
                    playerStats.get(playerName).red_cards++;
                  }
                }
              }
              
              // Substitution: "Player Out for Player In"
              if (text.includes(' for ')) {
                const match = text.match(/^(.+?)\s+for\s+(.+?)$/);
                if (match) {
                  const playerOut = match[1].trim();
                  const playerIn = match[2].trim();
                  
                  if (playerStats.has(playerOut)) {
                    playerStats.get(playerOut).sub_out_minute = minute;
                    playerStats.get(playerOut).minutes_played = minute;
                  }
                  
                  if (playerStats.has(playerIn)) {
                    playerStats.get(playerIn).sub_in_minute = minute;
                    playerStats.get(playerIn).minutes_played = 90 - minute;
                  }
                }
              }
            }
          }
        }
      }
      
      // Add team name to each player stat
      const result = Array.from(playerStats.values()).map(stat => ({
        ...stat,
        teamName: playerTeams.get(stat.name) || null
      }));
      
      return result;
    }
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
   * Parse standings table data from DOM element
   */
  parseStandingsTable(tableElement) {
    const rows = [];
    
    if (!tableElement) return rows;
    
    const tbody = tableElement.querySelector('tbody') || tableElement;
    const trs = tbody.querySelectorAll('tr');
    
    for (const tr of trs) {
      const cells = tr.querySelectorAll('td, th');
      if (cells.length < 10) continue; // Need at least 10 columns for full stats
      
      // APSL standings columns: Rank, Team, MP, W, D, L, GF, GA, GD, Pts
      const teamName = cells[1].textContent.trim();
      
      // Skip header rows
      if (!teamName || teamName === 'Team' || teamName === 'Rank' || cells[0].textContent.trim() === 'Rank') {
        continue;
      }
      
      rows.push({
        team: teamName,
        gp: parseInt(cells[2].textContent) || 0,  // MP (Matches Played)
        w: parseInt(cells[3].textContent) || 0,    // W (Wins)
        t: parseInt(cells[4].textContent) || 0,    // D (Draws/Ties)
        l: parseInt(cells[5].textContent) || 0,    // L (Losses)
        gf: parseInt(cells[6].textContent) || 0,   // GF (Goals For)
        ga: parseInt(cells[7].textContent) || 0,   // GA (Goals Against)
        gd: parseInt(cells[8].textContent) || 0,   // GD (Goal Differential)
        pts: parseInt(cells[9].textContent) || 0   // Pts (Points)
      });
    }
    
    return rows;
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
      // Cell 1: Location (e.g., "Lighthouse Field") - may contain Google Maps link
      // Cell 2: Match (e.g., "vs Philadelphia Soccer Club (4-3-2) (Regular Season)")
      // Cell 3: Result (e.g., "Loss (2 - 3) (view)") - if match is completed

      const dateText = cells[0]?.textContent.trim();
      const location = cells[1]?.textContent.trim();
      const matchText = cells[2]?.textContent.trim();
      const resultText = cells[3]?.textContent.trim();

      // Extract Google Maps link if present
      const locationLink = cells[1]?.querySelector('a');
      const googleMapsUrl = locationLink?.getAttribute('href') || null;

      // Extract match URL from "view" link in result cell (cell 3)
      let matchUrl = null;
      if (cells[3]) {
        const viewLink = Array.from(cells[3].querySelectorAll('a')).find(a => a.textContent.toLowerCase().includes('view'));
        if (viewLink) {
          matchUrl = viewLink.getAttribute('href');
        }
      }

      if (!dateText || !matchText) continue;
      
      // Parse match text to extract opponent
      // Format: "vs Philadelphia Soccer Club (4-3-2) (Regular Season)"
      // or: "@ Sewell Old Boys FC (1-2-8) (Regular Season)"
      
      // Extract home/away and opponent
      const isHome = matchText.includes('vs ');
      const opponentMatch = matchText.match(/(?:vs|@)\s+([^(]+)/);
      const opponent = opponentMatch ? opponentMatch[1].trim() : null;
      
      if (!opponent) continue;
      
      // Parse result from cells[3] if available
      // Format: "Win (5 - 1) (view)" or "Loss (2 - 3) (view)" or "Draw (0 - 0) (view)"
      let matchStatus = 'scheduled';
      let homeScore = null;
      let awayScore = null;
      let resultType = null;
      
      if (resultText) {
        const resultMatch = resultText.match(/(Win|Loss|Draw)\s*\((\d+)\s*-\s*(\d+)\)/i);
        if (resultMatch) {
          resultType = resultMatch[1].toLowerCase();
          const score1 = parseInt(resultMatch[2]);
          const score2 = parseInt(resultMatch[3]);
          
          // Determine which score is home/away based on result type and home/away status
          if (isHome) {
            // We are home team
            if (resultType === 'win') {
              homeScore = score1;
              awayScore = score2;
            } else if (resultType === 'loss') {
              homeScore = score2;
              awayScore = score1;
            } else { // draw
              homeScore = score1;
              awayScore = score2;
            }
          } else {
            // We are away team
            if (resultType === 'win') {
              awayScore = score1;
              homeScore = score2;
            } else if (resultType === 'loss') {
              awayScore = score2;
              homeScore = score1;
            } else { // draw
              awayScore = score1;
              homeScore = score2;
            }
          }
          
          matchStatus = 'completed';
        }
      }

      matches.push({
        date: this.parseDate(dateText),
        opponent: opponent,
        location: location || null,
        googleMapsUrl: googleMapsUrl,
        isHome: isHome,
        matchStatus: matchStatus,
        homeScore: homeScore,
        awayScore: awayScore,
        resultType: resultType,
        matchUrl: matchUrl
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
   * Parse player season statistics from roster page
   * Table has columns: Player, Goals, Assists
   */
  parsePlayerStats() {
    const playerStats = [];
    
    // Find the Active Roster table - look for table with "Goals" and "Assists" headers
    const tables = this.querySelectorAll('table.Table');
    let rosterTable = null;
    
    for (const table of tables) {
      // Check if table has th elements containing Goals and Assists
      const headers = table.querySelectorAll('th');
      let hasGoals = false;
      let hasAssists = false;
      
      for (const th of headers) {
        const text = th.textContent.trim();
        if (text === 'Goals') hasGoals = true;
        if (text === 'Assists') hasAssists = true;
      }
      
      if (hasGoals && hasAssists) {
        rosterTable = table;
        break;
      }
    }
    
    if (!rosterTable) {
      return playerStats;
    }
    
    // Process each player row
    const rows = rosterTable.querySelectorAll('tr.TableRow0, tr.TableRow1');
    
    for (const row of rows) {
      const cells = row.querySelectorAll('td');
      if (cells.length < 3) continue;
      
      // Cell 0: Empty or photo
      // Cell 1: Player name (in a div)
      // Cell 2: Goals
      // Cell 3: Assists
      
      const nameDiv = cells[1]?.querySelector('div[style*="font-size:12px"]');
      const playerName = nameDiv?.textContent.trim();
      const goalsText = cells[2]?.textContent.trim();
      const assistsText = cells[3]?.textContent.trim();
      
      if (!playerName || playerName.toLowerCase() === 'player') continue;
      
      // Parse goals and assists (empty cells mean 0)
      const goals = goalsText ? parseInt(goalsText) : 0;
      const assists = assistsText ? parseInt(assistsText) : 0;
      
      playerStats.push({
        name: playerName,
        goals: isNaN(goals) ? 0 : goals,
        assists: isNaN(assists) ? 0 : assists
      });
    }
    
    return playerStats;
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
