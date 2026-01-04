/**
 * Country Domain Model
 * 
 * Pure domain object with validation and business logic.
 * No database or external dependencies.
 */
class Country {
  constructor({ code, name, fifaCode, continentCode }) {
    this.code = code;
    this.name = name;
    this.fifaCode = fifaCode;
    this.continentCode = continentCode;
    
    this.validate();
  }
  
  validate() {
    if (!this.code || this.code.length !== 3) {
      throw new Error(`Invalid country code: ${this.code}`);
    }
    
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid country name: ${this.name}`);
    }
    
    if (this.fifaCode && this.fifaCode.length !== 3) {
      throw new Error(`Invalid FIFA code: ${this.fifaCode}`);
    }
  }
  
  /**
   * Convert to database row format
   * Note: continentId must be resolved by repository
   */
  toDbRow(continentId) {
    return {
      code: this.code,
      name: this.name,
      fifa_code: this.fifaCode,
      continent_id: continentId,
      is_active: true
    };
  }
  
  toString() {
    return `${this.name} (${this.code})${this.continentCode ? ` - ${this.continentCode}` : ''}`;
  }
}

module.exports = Country;
