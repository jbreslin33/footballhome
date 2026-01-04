/**
 * League Domain Model
 * 
 * Second level in hierarchy:
 * Organization → League → Season → Conference → Division → Team → Player
 */
class League {
  constructor({ name, displayName, organizationId, slug, isActive = true }) {
    this.name = name;
    this.displayName = displayName;
    this.organizationId = organizationId;
    this.slug = slug;
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid league name: ${this.name}`);
    }
    
    if (!this.organizationId) {
      throw new Error(`League must have an organization_id`);
    }
  }
  
  toDbRow() {
    return {
      name: this.name,
      display_name: this.displayName,
      organization_id: this.organizationId,
      slug: this.slug,
      is_active: this.isActive
    };
  }
  
  toString() {
    return `${this.displayName || this.name}`;
  }
}

module.exports = League;
