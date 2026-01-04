/**
 * Organization Domain Model
 * 
 * Top-level entity in soccer hierarchy:
 * Organization → League → Season → Conference → Division → Team → Player
 */
class Organization {
  constructor({ name, shortName = null, website = null, isActive = true }) {
    this.name = name;
    this.shortName = shortName;
    this.website = website;
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid organization name: ${this.name}`);
    }
  }
  
  toDbRow() {
    return {
      name: this.name,
      short_name: this.shortName,
      website_url: this.website,
      is_active: this.isActive
    };
  }
  
  toString() {
    return `${this.shortName || this.name}`;
  }
}

module.exports = Organization;
