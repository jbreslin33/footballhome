/**
 * League Domain Model
 * 
 * Second level in hierarchy:
 * Organization → League → Season → Conference → Division → Team → Player
 */
class League {
  constructor({ name, organizationId = null, externalId = null, isActive = true }) {
    this.name = name;
    this.organizationId = organizationId;
    this.externalId = externalId;
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid league name: ${this.name}`);
    }
    
    // organizationId can be null during construction, but must be set before saving
  }
  
  toDbRow() {
    return {
      name: this.name,
      organization_id: this.organizationId,
      external_id: this.externalId,
      is_active: this.isActive
    };
  }
  
  toString() {
    return `${this.name}`;
  }
}

module.exports = League;
