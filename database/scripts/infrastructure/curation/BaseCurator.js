/**
 * Base Curator - Common curation logic
 * 
 * Provides fuzzy matching, SQL generation, and shared utilities.
 * Extended by LeagueCurator and entity-specific curators.
 */
class BaseCurator {
  constructor(pool) {
    this.pool = pool;
    this.sqlStatements = [];
  }

  /**
   * Fuzzy match two strings (removes special chars, case-insensitive)
   */
  fuzzyMatch(str1, str2) {
    const normalize = (s) => s
      .toLowerCase()
      .replace(/[^a-z0-9]/g, '')
      .trim();
    
    return normalize(str1) === normalize(str2);
  }

  /**
   * Calculate similarity score (0-1) between two strings
   */
  similarity(str1, str2) {
    const s1 = str1.toLowerCase();
    const s2 = str2.toLowerCase();
    
    // Exact match
    if (s1 === s2) return 1.0;
    
    // Contains check
    if (s1.includes(s2) || s2.includes(s1)) return 0.8;
    
    // Levenshtein distance (simple version)
    const longer = s1.length > s2.length ? s1 : s2;
    const shorter = s1.length > s2.length ? s2 : s1;
    
    if (longer.length === 0) return 1.0;
    
    const editDistance = this.levenshtein(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  /**
   * Levenshtein distance between two strings
   */
  levenshtein(str1, str2) {
    const costs = [];
    for (let i = 0; i <= str1.length; i++) {
      let lastValue = i;
      for (let j = 0; j <= str2.length; j++) {
        if (i === 0) {
          costs[j] = j;
        } else if (j > 0) {
          let newValue = costs[j - 1];
          if (str1.charAt(i - 1) !== str2.charAt(j - 1)) {
            newValue = Math.min(Math.min(newValue, lastValue), costs[j]) + 1;
          }
          costs[j - 1] = lastValue;
          lastValue = newValue;
        }
      }
      if (i > 0) costs[str2.length] = lastValue;
    }
    return costs[str2.length];
  }

  /**
   * Add SQL statement to the batch
   */
  addSql(sql, description) {
    this.sqlStatements.push({ sql, description });
  }

  /**
   * Generate SQL file
   */
  generateSqlFile(leagueId, leagueName) {
    const header = `-- ============================================================================
-- ${leagueName} Curation
-- ============================================================================
-- Generated: ${new Date().toISOString()}
-- Merges duplicate clubs/organizations from ${leagueName} into existing entities
-- ============================================================================

`;

    if (this.sqlStatements.length === 0) {
      return header + '-- No duplicates found - all entities are unique.\n';
    }

    let sql = header;
    
    for (const { sql: statement, description } of this.sqlStatements) {
      sql += `\n-- ${description}\n${statement}\n`;
    }

    return sql;
  }

  /**
   * Execute query
   */
  async query(sql, params = []) {
    const result = await this.pool.query(sql, params);
    return result.rows;
  }
}

module.exports = BaseCurator;
