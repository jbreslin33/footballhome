/**
 * Base SQL Curator
 * 
 * Reads SQL files from multiple leagues and merges duplicate entities.
 * Extended by league-specific curators.
 */
class BaseSqlCurator {
  constructor() {
    this.organizations = new Map(); // name -> org data
    this.clubs = new Map(); // name -> club data
    this.teams = []; // array of team data
  }

  /**
   * Parse organization INSERT statements from SQL
   */
  parseOrganizationsSql(sql) {
    const orgs = [];
    const regex = /INSERT INTO organizations \(id, name\) VALUES \((\d+), '((?:[^']|'')+)'\)/g;
    
    let match;
    while ((match = regex.exec(sql)) !== null) {
      orgs.push({
        id: parseInt(match[1]),
        name: match[2].replace(/''/g, "'")
      });
    }
    
    return orgs;
  }

  /**
   * Parse club INSERT statements from SQL
   */
  parseClubsSql(sql) {
    const clubs = [];
    
    const regex = /INSERT INTO clubs \(id, name, organization_id\) VALUES \((\d+), '((?:[^']|'')+)', (\d+)\)/g;
    let match;
    while ((match = regex.exec(sql)) !== null) {
      clubs.push({
        id: parseInt(match[1]),
        name: match[2].replace(/''/g, "'"),
        organizationId: parseInt(match[3])
      });
    }
    
    return clubs;
  }

  /**
   * Parse team INSERT statements from SQL (NEW SCHEMA FORMAT)
   * Format: INSERT INTO teams (name, external_id, club_id, division_id, source_system_id)
   *         SELECT '...', '...', club_id, d.id, source_id FROM divisions d...
   */
  parseTeamsSql(sql) {
    const teams = [];
    
    // New schema format: INSERT...SELECT with division_id lookup (multi-line)
    // Use dotall flag (s) to match across newlines
    // Note: Use (?:[^']|'')+ to handle SQL-escaped apostrophes (e.g., "Men''s")
    const regex = /INSERT INTO teams \(name, external_id, club_id, division_id, source_system_id\)\s+SELECT '((?:[^']|'')+)', '((?:[^']|'')+)', (\d+), d\.id, (\d+)/gs;
    
    let match;
    while ((match = regex.exec(sql)) !== null) {
      teams.push({
        id: null, // ID is auto-generated, not in SQL anymore
        name: match[1].replace(/''/g, "'"),
        externalId: match[2].replace(/''/g, "'"),
        clubId: parseInt(match[3]),
        sourceSystemId: parseInt(match[4])
      });
    }
    
    return teams;
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
      .trim();
  }

  /**
   * Normalize club name for grouping (strip FC, SC, CF, United, etc.)
   * This is used to group teams from the same club
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
   * Group teams by normalized club name (same club = same group)
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
   * Convert name to slug for family matching
   */
  toSlug(name) {
    return name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-|-$/g, '');
  }

  /**
   * Fuzzy match two club names
   */
  fuzzyMatch(name1, name2) {
    const norm1 = this.normalizeClubName(name1);
    const norm2 = this.normalizeClubName(name2);
    
    // Exact normalized match
    if (norm1 === norm2) return true;
    
    // One normalized name contains the other
    if (norm1.includes(norm2) || norm2.includes(norm1)) return true;
    
    // Check family mappings (override in subclass)
    const slug1 = this.toSlug(norm1);
    const slug2 = this.toSlug(norm2);
    const family1 = this.getClubFamily(slug1);
    const family2 = this.getClubFamily(slug2);
    if (family1 && family2 && family1 === family2) return true;
    
    return false;
  }

  /**
   * Get club family (override in subclass for league-specific rules)
   */
  getClubFamily(baseName) {
    return null;
  }

  /**
   * Find matching club in existing clubs
   */
  findMatchingClub(clubName, existingClubs) {
    for (const existingClub of existingClubs) {
      if (this.fuzzyMatch(clubName, existingClub.name)) {
        return existingClub;
      }
    }
    return null;
  }

  /**
   * Escape SQL string
   */
  escapeSql(str) {
    return str.replace(/'/g, "''");
  }

  /**
   * Generate SQL header (no timestamp to avoid git noise)
   */
  generateSqlHeader(title, description) {
    return `-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ${title}
-- ${description}
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

`;
  }

  /**
   * Main curation workflow (override in subclass)
   */
  async curate() {
    throw new Error('curate() must be implemented by subclass');
  }
}

module.exports = BaseSqlCurator;
