/**
 * Conference Domain Model
 * 
 * Fourth level in hierarchy:
 * Organization → League → Season → Conference → Division → Team → Player
 */
class Conference {
  constructor({ name, seasonId = null, externalId = null, isActive = true }) {
    this.name = name;
    this.seasonId = seasonId;
    this.externalId = externalId; // APSL's conference ID
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid conference name: ${this.name}`);
    }
    
    // seasonId can be null during construction, but must be set before saving
  }
  
  toDbRow() {
    return {
      name: this.name,
      season_id: this.seasonId,
      external_id: this.externalId
    };
  }
  
  toString() {
    return `${this.name}`;
  }
}

module.exports = Conference;
