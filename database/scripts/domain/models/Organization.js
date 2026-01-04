/**
 * Organization Domain Model
 * 
 * Top-level entity in soccer hierarchy:
 * Organization → League → Season → Conference → Division → Team → Player
 */
class Organization {
  constructor({ name, displayName, slug, website, isActive = true }) {
    this.name = name;
    this.displayName = displayName;
    this.slug = slug;
    this.website = website;
    this.isActive = isActive;
    
    this.validate();
  }
  
  validate() {
    if (!this.name || this.name.trim().length === 0) {
      throw new Error(`Invalid organization name: ${this.name}`);
    }
    
    if (!this.slug || this.slug.trim().length === 0) {
      throw new Error(`Invalid organization slug: ${this.slug}`);
    }
  }
  
  toDbRow() {
    return {
      name: this.name,
      display_name: this.displayName,
      slug: this.slug,
      website: this.website,
      is_active: this.isActive
    };
  }
  
  toString() {
    return `${this.displayName || this.name} (${this.slug})`;
  }
}

module.exports = Organization;
