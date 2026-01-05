/**
 * Club Domain Model
 */
class Club {
  constructor({ 
    name,
    organizationId,
    sportId = 1, // Default to soccer
    logoUrl = null,
    website = null,
    isActive = true
  }) {
    this.name = name;
    this.organizationId = organizationId;
    this.sportId = sportId;
    this.logoUrl = logoUrl;
    this.website = website;
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid club name: ${this.name}`);
    }
    if (!this.organizationId) {
      throw new Error('Club must have an organization_id');
    }
  }
  
  toString() {
    return this.name;
  }
}

module.exports = Club;
