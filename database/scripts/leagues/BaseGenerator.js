/**
 * Base class for league SQL generators
 * Provides common functionality for parsing HTML and generating SQL
 */
class BaseGenerator {
  constructor(leagueName, sourceSystemId, leagueId, orgIdBase, clubIdBase, teamIdBase) {
    this.leagueName = leagueName;
    this.sourceSystemId = sourceSystemId;
    this.leagueId = leagueId;
    this.orgIdBase = orgIdBase;
    this.clubIdBase = clubIdBase;
    this.teamIdBase = teamIdBase;
    
    // Common data structures for all leagues
    this.organizations = new Map();
    this.clubs = new Map();
    this.teams = [];
    this.standings = [];
    this.divisionTeams = [];
    this.divisions = new Map();
    this.players = [];
  }

  /**
   * Get club base name (strip reserve indicators)
   */
  getClubBaseName(name) {
    return name
      .replace(/\s+(II|III|IV|V|2|3|4|5)$/i, '')
      .replace(/\s+Reserve$/i, '')
      .replace(/\s+Reserves$/i, '')
      .replace(/\s+Legends$/i, '')
      .replace(/\s+Old Boys$/i, '')
      .replace(/\s+Masters$/i, '')
      .replace(/\s+Bhoys$/i, '')
      .replace(/\s+Lower East$/i, '')
      .replace(/\s+Hudson$/i, '')
      .replace(/\s+OG\'?S$/i, '')
      .replace(/\s+Dawgz$/i, '')
      .replace(/\s+Red$/i, '')
      .replace(/\s+Green$/i, '')
      .replace(/\s+Blue$/i, '')
      .replace(/\s+White$/i, '')
      .replace(/\s+Black$/i, '')
      .replace(/\s+Orange$/i, '')
      .replace(/\s+Yellow$/i, '')
      .replace(/\s+Yellow\s+Hook$/i, '')
      .replace(/\s+Over-?\d+$/i, '')
      .replace(/\s+Young\s+Boys$/i, '')
      .replace(/\s+United$/i, '')
      .replace(/\s+1999$/i, '')
      .replace(/\s+Veterans?$/i, '')
      .replace(/\s+Old\s+Timers?$/i, '')
      .replace(/\s+Boys?\s+Club$/i, '')
      .replace(/\s+City$/i, '')
      .replace(/\s+Fury$/i, '')
      .replace(/\s+Kickoff$/i, '')
      .trim();
  }

  /**
   * Normalize club name for grouping (strip FC, SC, CF, etc.)
   */
  normalizeClubName(name) {
    const base = this.getClubBaseName(name);
    return base
      .replace(/\s+(FC|SC|CF|United|City|Club|AFC|SFC|CFC|SCM|SCR|FCW|FCA)$/i, '')
      .replace(/\b(FC|SC|CF|United|City|Club|SCM|SCR|FCW|FCA)\b/gi, '')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();
  }

  /**
   * Group teams by normalized club name
   * Returns Map<normalizedName, teams[]>
   */
  groupTeamsByClub(teams) {
    const groups = new Map();
    
    for (const team of teams) {
      const normalized = this.normalizeClubName(team.name);
      if (!groups.has(normalized)) {
        groups.set(normalized, []);
      }
      groups.get(normalized).push(team);
    }
    
    return groups;
  }

  /**
   * Extract unique clubs from grouped teams
   * Returns Map<clubName, club>
   * Also sets clubName on each team
   */
  extractClubsFromGroups(teamGroups) {
    const clubs = new Map();
    let clubId = this.clubIdBase;

    for (const [normalizedName, teams] of teamGroups) {
      // Use the first team's base name as the club name
      const clubName = this.getClubBaseName(teams[0].name);
      
      if (!clubs.has(clubName)) {
        clubs.set(clubName, {
          id: clubId++,
          name: clubName,
          teams: teams
        });
        
        // Set clubName on each team in the group
        for (const team of teams) {
          team.clubName = clubName;
        }
      }
    }

    return clubs;
  }

  /**
   * Extract unique organizations from clubs
   * Returns Map<orgName, org>
   * Also sets organizationName on each club
   */
  extractOrganizationsFromClubs(clubs) {
    const organizations = new Map();
    let orgId = this.orgIdBase;

    for (const [clubName, club] of clubs) {
      if (!organizations.has(clubName)) {
        organizations.set(clubName, {
          id: orgId++,
          name: clubName
        });
      }
      // Set organizationName on club (1:1 mapping)
      club.organizationName = clubName;
    }

    return organizations;
  }

  /**
   * Extract distinctive words from club name (excluding common soccer terms)
   * Returns array of significant words that could indicate club identity
   */
  extractDistinctiveWords(name) {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9\s]/g, ' ')
      .split(/\s+/)
      .filter(word => word.length > 2);
  }

  /**
   * Check if a word is a common soccer/geographic term
   */
  isCommonWord(word) {
    const commonTerms = new Set([
      // Soccer org types
      'fc', 'sc', 'cf', 'afc', 'sfc', 'cfc', 'scm', 'scr', 'fca', 'fcw',
      'united', 'city', 'club', 'football', 'soccer',
      'athletic', 'sports', 'sporting', 'association', 'academy',
      
      // Geographic - NYC
      'ny', 'nyc', 'new', 'york', 'brooklyn', 'manhattan', 'queens', 'bronx',
      'staten', 'island', 'yonkers', 'harlem', 'astoria',
      
      // Geographic - Other common
      'north', 'south', 'east', 'west', 'central', 'upper', 'lower',
      'shore', 'coast', 'county', 'valley', 'park', 'riverside',
      'jersey', 'philadelphia', 'philly',
      
      // Common descriptors
      'international', 'world', 'global', 'national',
      'real', 'royal', 'inter', 'union',
      
      // Team types
      'ii', 'iii', 'iv', 'reserve', 'reserves', 'legends',
      'old', 'boys', 'masters', 'veterans', 'timers',
      'young', 'youth', 'junior', 'senior',
      
      // Colors (common suffixes)
      'red', 'blue', 'green', 'white', 'black', 'yellow', 'orange'
    ]);
    
    return commonTerms.has(word.toLowerCase());
  }

  /**
   * Find potential duplicate clubs based on distinctive word matches
   * Compares existing clubs with new clubs and flags suspicious partial matches
   * @param {Array} existingClubs - Clubs already in database (e.g., APSL clubs)
   * @param {Array} newClubs - New clubs being added (e.g., CSL clubs)
   * @returns {Array} Array of potential duplicate warnings
   */
  findPotentialDuplicates(existingClubs, newClubs) {
    const warnings = [];
    
    for (const newClub of newClubs) {
      const newWords = this.extractDistinctiveWords(newClub.name);
      
      for (const existingClub of existingClubs) {
        const existingWords = this.extractDistinctiveWords(existingClub.name);
        
        // Check if any distinctive word matches
        const matchingWords = newWords.filter(word => existingWords.includes(word));
        
        if (matchingWords.length > 0) {
          // Check if they're already matched (normalized names equal)
          const newNormalized = this.normalizeClubName(newClub.name);
          const existingNormalized = this.normalizeClubName(existingClub.name);
          
          // Only warn if they share words but aren't already matched
          if (newNormalized !== existingNormalized) {
            // Determine severity based on match quality
            let severity;
            
            // 2+ words match = HIGH (even if common words, the combination is distinctive)
            if (matchingWords.length >= 2) {
              severity = 'HIGH';
            }
            // 1 word matches and it's NOT common = MEDIUM
            else if (matchingWords.length === 1 && !this.isCommonWord(matchingWords[0])) {
              severity = 'MEDIUM';
            }
            // 1 common word match = ignore (too many false positives)
            else {
              continue;
            }
            
            warnings.push({
              newClub: newClub.name,
              existingClub: existingClub.name,
              matchingWords: matchingWords,
              severity: severity
            });
          }
        }
      }
    }
    
    return warnings;
  }

  /**
   * Escape SQL string
   */
  escapeSql(str) {
    return str.replace(/'/g, "''");
  }

  /**
   * Write division_teams SQL (common for all leagues)
   * Generates SQL file 103-division-teams-{league}.sql
   */
  writeDivisionTeamsSql() {
    const fs = require('fs');
    const path = require('path');
    
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Division Teams - ${this.leagueName}
-- Associates teams with their divisions
-- Total Records: ${this.teams.length}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let teamId = this.teamIdBase;
    for (const team of this.teams) {
      // Division lookup by name for current season (2025/2026 = season_id 1)
      // No ON CONFLICT - table has no unique constraint (allows promotion/relegation history)
      sql += `INSERT INTO division_teams (division_id, team_id)
SELECT d.id, ${teamId}
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = '${this.escapeSql(team.divisionName)}'
  AND s.name = '2025/2026';\n`;
      teamId++;
    }

    const outputPath = path.join(__dirname, this.getLeagueFolder(), 'sql', `103.${this.leagueId}-division-teams-${this.getLeagueFolder()}.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write standings SQL (common for all leagues)
   * Generates SQL file 104-standings-{league}.sql
   */
  writeStandingsSql() {
    const fs = require('fs');
    const path = require('path');
    
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Standings - ${this.leagueName}
-- Current season standings data
-- Total Records: ${this.teams.length}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    const fetchedAt = new Date().toISOString();
    let teamId = this.teamIdBase;
    
    for (const team of this.teams) {
      const st = team.standings;
      if (!st) continue; // Skip if no standings data
      
      // Lookup division_id and season_id for current season
      // competition_id = division_id (each division is its own competition)
      // JOIN divisions to seasons to avoid matching old divisions with same name
      sql += `INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT d.id, s.id, ${teamId}, ${st.position}, ${st.played}, ${st.wins}, ${st.draws}, ${st.losses}, ${st.goalsFor}, ${st.goalsAgainst}, ${st.goalDiff}, ${st.points}, '${fetchedAt}', '${this.leagueName} Scraper'
FROM divisions d
JOIN seasons s ON d.season_id = s.id
WHERE d.name = '${this.escapeSql(team.divisionName)}'
  AND s.name = '2025/2026'
  AND s.league_id = ${this.sourceSystemId}
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET
  position = EXCLUDED.position,
  played = EXCLUDED.played,
  wins = EXCLUDED.wins,
  draws = EXCLUDED.draws,
  losses = EXCLUDED.losses,
  goals_for = EXCLUDED.goals_for,
  goals_against = EXCLUDED.goals_against,
  goal_diff = EXCLUDED.goal_diff,
  points = EXCLUDED.points,
  fetched_at = EXCLUDED.fetched_at;\n`;
  
      teamId++;
    }

    const outputPath = path.join(__dirname, this.getLeagueFolder(), 'sql', `104.${this.leagueId}-standings-${this.getLeagueFolder()}.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Write players SQL (common for all leagues)
   * Generates SQL file 105-players-{league}.sql
   */
  writePlayersSql() {
    const fs = require('fs');
    const path = require('path');
    
    if (this.players.length === 0) {
      console.log(`   ⚠ No players found - skipping 105-players SQL`);
      return;
    }
    
    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Players - ${this.leagueName}
-- Player roster data from team pages
-- Total Records: ${this.players.length}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    let playerId = this.getPlayerIdBase();
    for (const player of this.players) {
      const firstName = player.firstName || '';
      const lastName = player.lastName || '';
      
      sql += `INSERT INTO persons (id, first_name, last_name) 
VALUES (${playerId}, '${this.escapeSql(firstName)}', '${this.escapeSql(lastName)}') 
ON CONFLICT (id) DO NOTHING;\n`;
      
      sql += `INSERT INTO players (id, person_id) 
VALUES (${playerId}, ${playerId}) 
ON CONFLICT (id) DO NOTHING;\n\n`;
      
      playerId++;
    }

    const outputPath = path.join(__dirname, this.getLeagueFolder(), 'sql', `105.${this.leagueId}-players-${this.getLeagueFolder()}.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Get player ID base (must be implemented by subclass)
   */
  getPlayerIdBase() {
    throw new Error('getPlayerIdBase() must be implemented by subclass');
  }

  /**
   * Get league folder name (must be implemented by subclass)
   */
  getLeagueFolder() {
    throw new Error('getLeagueFolder() must be implemented by subclass');
  }
}

module.exports = BaseGenerator;
