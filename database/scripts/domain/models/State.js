/**
 * State Domain Model
 * 
 * Represents a state/province within a country.
 */
class State {
  constructor({ code, name, countryId = null, isActive = true }) {
    this.code = code;
    this.name = name;
    this.countryId = countryId;
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.code || this.code.length !== 2) {
      throw new Error(`Invalid state code: ${this.code} (must be 2 characters)`);
    }
    
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid state name: ${this.name}`);
    }
    
    // countryId can be null during construction, but must be set before saving
  }
  
  toDbRow() {
    return {
      code: this.code,
      name: this.name,
      country_id: this.countryId,
      is_active: this.isActive
    };
  }
  
  toString() {
    return `${this.name} (${this.code})`;
  }
}

module.exports = State;
