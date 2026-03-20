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
    this.rosters = [];  // NEW: Store player-team relationships
    this.matches = [];  // NEW: Store parsed matches
    this.matchSet = new Set();  // NEW: Deduplicate matches
    this.venues = new Map();  // NEW: Store unique venues
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
   * Write standings SQL (common for all leagues)
   * Generates SQL file 104-standings-{league}.sql
   * 
   * NEW SCHEMA: Simplified - team_id only (division/season implied via FK chain)
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
    
    for (const team of this.teams) {
      const st = team.standings;
      if (!st) continue; // Skip if no standings data
      
      // Lookup team_id by name and division
      // Division/season context automatically included via team.division_id FK
      sql += `INSERT INTO standings (team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT t.id, ${st.position}, ${st.played}, ${st.wins}, ${st.draws}, ${st.losses}, ${st.goalsFor}, ${st.goalsAgainst}, ${st.goalDiff}, ${st.points}, '${fetchedAt}', '${this.leagueName} Scraper'
FROM teams t
JOIN divisions d ON t.division_id = d.id
JOIN seasons s ON d.season_id = s.id
WHERE t.name = '${this.escapeSql(team.name)}'
  AND d.name = '${this.escapeSql(team.divisionName)}'
  AND s.name = '${this.getSeasonName()}'
  AND s.league_id = ${this.getLeagueId()}
ON CONFLICT (team_id) DO UPDATE SET
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
    }

    const outputPath = path.join(__dirname, this.getLeagueFolder(), 'sql', `104.${this.leagueId}-standings-${this.getLeagueSlug()}.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Slugify a string for use as an external_id component
   */
  slugify(str) {
    return str
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '')  // Remove diacritics
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  /**
   * Write players SQL (common for all leagues)
   * Generates SQL file 105-players-{league}.sql
   * 
   * NEW: Uses auto-generated IDs with name-based conflict resolution.
   * - persons: ON CONFLICT (first_name, last_name) DO UPDATE (fill birth_date)
   * - players: ON CONFLICT (person_id) DO NOTHING (one player per person)
   * - player_sources: ON CONFLICT DO UPDATE (track team changes)
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
-- 
-- Architecture: Auto-generated IDs, name-based deduplication
-- Same name = same person across all sources (curation overrides via name change)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;

    for (const player of this.players) {
      const firstName = player.firstName || '';
      const lastName = player.lastName || '';
      const birthDate = player.dateOfBirth ? `'${player.dateOfBirth}'` : 'NULL';
      
      // 1. Insert person (auto-gen ID, fill birth_date if missing)
      sql += `INSERT INTO persons (first_name, last_name, birth_date) 
VALUES ('${this.escapeSql(firstName)}', '${this.escapeSql(lastName)}', ${birthDate}) 
ON CONFLICT (first_name, last_name) DO UPDATE SET
  birth_date = COALESCE(EXCLUDED.birth_date, persons.birth_date);\n`;
      
      // 2. Insert player (auto-gen ID, one per person, skip if person already has a player record)
      sql += `INSERT INTO players (person_id, source_system_id) 
SELECT id, ${this.sourceSystemId} FROM persons 
WHERE first_name = '${this.escapeSql(firstName)}' AND last_name = '${this.escapeSql(lastName)}' 
ON CONFLICT (person_id) DO NOTHING;\n`;
      
      // 3. Insert player_source (track this source system observation)
      const teamName = player.teamName || '';
      const externalId = this.slugify(teamName + '-' + firstName + '-' + lastName);
      const teamExternalId = player.teamExternalId || '';
      
      sql += `INSERT INTO player_sources (player_id, source_system_id, external_id, team_external_id) 
SELECT pl.id, ${this.sourceSystemId}, '${this.escapeSql(externalId)}', ${teamExternalId ? `'${this.escapeSql(teamExternalId)}'` : 'NULL'}
FROM players pl 
JOIN persons per ON pl.person_id = per.id 
WHERE per.first_name = '${this.escapeSql(firstName)}' AND per.last_name = '${this.escapeSql(lastName)}' 
ON CONFLICT (source_system_id, external_id) DO UPDATE SET
  team_external_id = EXCLUDED.team_external_id;\n\n`;
    }

    const outputPath = path.join(__dirname, this.getLeagueFolder(), 'sql', `105.${this.leagueId}-players-${this.getLeagueSlug()}.sql`);
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
   * Write rosters SQL (player-team relationships)
   * 
   * NEW: Looks up player by person name instead of hardcoded ID.
   * Players are matched via persons(first_name, last_name) → players(person_id).
   */
  writeRostersSql() {
    const fs = require('fs');
    const path = require('path');
    
    if (this.rosters.length === 0) {
      console.log(`   ⚠ No rosters found - skipping 107-rosters SQL`);
      return;
    }

    let sql = `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Rosters - ${this.leagueName}
-- Player-team relationships from team roster pages
-- Total Records: ${this.rosters.length}
-- 
-- Architecture: Players looked up by name (no hardcoded IDs)
-- joined_at uses sentinel date '1970-01-01' for scraped rosters (deterministic for UPSERT)
-- Full replace: DELETE all rosters for this source system's teams, then re-INSERT current roster
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

-- Remove all existing roster entries for teams in this source system
-- This ensures players removed from the official roster are also removed from the DB
DELETE FROM rosters WHERE team_id IN (SELECT id FROM teams WHERE source_system_id = ${this.sourceSystemId});

`;

    for (const roster of this.rosters) {
      const { firstName, lastName, teamName, jerseyNumber } = roster;
      const jerseyNumSql = jerseyNumber ? `'${jerseyNumber}'` : 'NULL';
      
      // Look up team by name and player by person name
      // Use fixed sentinel date so (team_id, player_id, joined_at) conflict key is deterministic
      sql += `INSERT INTO rosters (team_id, player_id, jersey_number, joined_at) 
SELECT t.id, pl.id, ${jerseyNumSql}, '1970-01-01'
FROM teams t, players pl
JOIN persons per ON pl.person_id = per.id
WHERE t.name = '${this.escapeSql(teamName)}' AND t.source_system_id = ${this.sourceSystemId}
  AND per.first_name = '${this.escapeSql(firstName)}' AND per.last_name = '${this.escapeSql(lastName)}'
ON CONFLICT (team_id, player_id, joined_at) DO UPDATE SET
  jersey_number = EXCLUDED.jersey_number;\n\n`;
    }

    const outputPath = path.join(__dirname, this.getLeagueFolder(), 'sql', `107.${this.leagueId}-rosters-${this.getLeagueSlug()}.sql`);
    fs.writeFileSync(outputPath, sql);
    console.log(`   ✓ ${outputPath}`);
  }

  /**
   * Get league folder path relative to leagues/ directory
   * e.g., 'north-america/usa/apsl'
   */
  getLeagueFolder() {
    throw new Error('getLeagueFolder() must be implemented by subclass');
  }

  /**
   * Get league slug for SQL filenames
   * e.g., 'apsl', 'csl', 'casa'
   */
  getLeagueSlug() {
    throw new Error('getLeagueSlug() must be implemented by subclass');
  }

  /**
   * Get active season name for this league (must be implemented by subclass)
   * @returns {string} Season name (e.g., "2025/2026", "2022/2023")
   */
  getSeasonName() {
    throw new Error('getSeasonName() must be implemented by subclass');
  }

  /**
   * Get league ID from leagues table (must be implemented by subclass)
   * @returns {number} League ID (e.g., 1=APSL, 4=CSL)
   */
  getLeagueId() {
    throw new Error('getLeagueId() must be implemented by subclass');
  }

  /**
   * Look up a team name by its external ID
   * @param {string} externalId - Team external ID
   * @returns {string} Team name or empty string
   */
  getTeamNameByExternalId(externalId) {
    if (!externalId) return '';
    const team = this.teams.find(t => t.externalId === String(externalId));
    return team ? team.name : '';
  }

  /**
   * Add a match to the matches collection
   * Deduplicates by match key (date + teams)
   * @param {Object} matchData - Match data from parser
   */
  addMatch(matchData) {
    // Create unique key: date-homeTeam-awayTeam
    const key = `${matchData.matchDate}-${matchData.homeTeamExternalId}-${matchData.awayTeamExternalId}`;
    
    // Skip if already added (matches appear on both home and away team pages)
    if (this.matchSet.has(key)) {
      return;
    }
    
    this.matchSet.add(key);
    this.matches.push(matchData);
  }

  /**
   * Add or get venue ID
   * @param {string} venueName - Venue name
   * @param {string} address - Venue address (optional)
   * @returns {number} Venue ID
   */
  getOrCreateVenue(venueName, address = null) {
    if (!venueName) return null;
    
    const key = venueName.toLowerCase().trim();
    if (!this.venues.has(key)) {
      const venueId = 1000 + this.venues.size;
      this.venues.set(key, {
        id: venueId,
        name: venueName,
        address: address
      });
    }
    return this.venues.get(key).id;
  }

}

module.exports = BaseGenerator;
