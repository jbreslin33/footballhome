/**
 * Season Domain Model
 * 
 * Third level in hierarchy:
 * Organization → League → Season → Conference → Division → Team → Player
 */
class Season {
  constructor({ 
    name, 
    leagueId = null, 
    startDate = null, 
    endDate = null, 
    sourceSystemId = null,
    externalId = null,
    isActive = true 
  }) {
    this.name = name;
    this.leagueId = leagueId;
    this.sourceSystemId = sourceSystemId;
    this.externalId = externalId;
    this.isActive = isActive;
    
    // Auto-calculate dates from season name if not provided
    // Season name format: "YYYY/YYYY" (e.g., "2025/2026")
    // Default: September 1st of first year to June 30th of second year
    if (!startDate || !endDate) {
      const dates = this.calculateSeasonDates(name);
      this.startDate = startDate || dates.startDate;
      this.endDate = endDate || dates.endDate;
    } else {
      this.startDate = startDate;
      this.endDate = endDate;
    }
    
    this.validate();
  }
  
  /**
   * Calculate season start/end dates from season name
   * @param {string} name - Season name in format "YYYY/YYYY"
   * @returns {object} { startDate, endDate }
   */
  calculateSeasonDates(name) {
    // Match "2025/2026" format
    const match = name.match(/(\d{4})\/(\d{4})/);
    if (match) {
      const startYear = parseInt(match[1], 10);
      const endYear = parseInt(match[2], 10);
      return {
        startDate: `${startYear}-09-01`,  // September 1st
        endDate: `${endYear}-06-30`       // June 30th
      };
    }
    return { startDate: null, endDate: null };
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid season name: ${this.name}`);
    }
    
    // leagueId can be null during construction, but must be set before saving
  }
  
  toDbRow() {
    return {
      name: this.name,
      league_id: this.leagueId,
      start_date: this.startDate,
      end_date: this.endDate,
      source_system_id: this.sourceSystemId,
      external_id: this.externalId,
      is_active: this.isActive
    };
  }
  
  toString() {
    return `${this.name}`;
  }
}

module.exports = Season;
