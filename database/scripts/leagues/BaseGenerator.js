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
      .replace(/\s+(FC|SC|CF|United|City|Club|AFC|SFC|CFC|SCM|SCR)$/i, '')
      .replace(/\b(FC|SC|CF|United|City|Club|SCM|SCR)\b/gi, '')
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
}

module.exports = BaseGenerator;
