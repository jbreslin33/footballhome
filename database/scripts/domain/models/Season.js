/**
 * Season Domain Model
 * 
 * Third level in hierarchy:
 * Organization → League → Season → Conference → Division → Team → Player
 */
class Season {
  constructor({ name, leagueId = null, startDate = null, endDate = null, isActive = true }) {
    this.name = name;
    this.leagueId = leagueId;
    this.startDate = startDate;
    this.endDate = endDate;
    this.isActive = isActive;
    
    this.validate();
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
      is_active: this.isActive
    };
  }
  
  toString() {
    return `${this.name}`;
  }
}

module.exports = Season;
