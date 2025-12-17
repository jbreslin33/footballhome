const SqlGenerator = require('../services/SqlGenerator');

/**
 * Coach Model - Extends User with coaching-specific attributes
 * Database: coaches table references users(id)
 */
class Coach {
  constructor(data) {
    this.id = data.id; // Same UUID as user.id
    this.coaching_license = data.coaching_license || null;
    this.license_expiry = data.license_expiry || null;
    this.years_experience = data.years_experience || null;
    this.certifications = data.certifications || null; // TEXT[] array
    this.specializations = data.specializations || null; // TEXT[] array
    this.bio = data.bio || null;
  }

  /**
   * Generate SQL INSERT for coaches table
   */
  toSQL() {
    const certArray = this.certifications ? `ARRAY[${this.certifications.map(c => SqlGenerator.escape(c)).join(', ')}]` : 'NULL';
    const specArray = this.specializations ? `ARRAY[${this.specializations.map(s => SqlGenerator.escape(s)).join(', ')}]` : 'NULL';

    return `(${SqlGenerator.escape(this.id)}, ${SqlGenerator.escape(this.coaching_license)}, ${SqlGenerator.escape(this.license_expiry)}, ${SqlGenerator.escape(this.years_experience)}, ${certArray}, ${specArray}, ${SqlGenerator.escape(this.bio)})`;
  }

  /**
   * Validate required fields
   */
  static validate(data) {
    if (!data.id) {
      throw new Error('Coach requires id (same as user id)');
    }
    return true;
  }
}

module.exports = Coach;
