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
      .replace(/\s+Young\s+Boys$/i, '')
      .replace(/\s+United$/i, '')
      .replace(/\s+1999$/i, '')
      .replace(/\s+Veterans?$/i, '')
      .replace(/\s+Old\s+Timers?$/i, '')
      .replace(/\s+Boys?\s+Club$/i, '')
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
   * Escape SQL string
   */
  escapeSql(str) {
    return str.replace(/'/g, "''");
  }
}

module.exports = BaseGenerator;
