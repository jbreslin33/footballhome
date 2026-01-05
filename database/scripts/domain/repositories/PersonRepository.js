/**
 * Person Repository
 * All database operations for persons (core identity)
 */
class PersonRepository {
  constructor(db) {
    this.db = db;
  }
  
  /**
   * Find person by first and last name
   */
  async findByName(firstName, lastName) {
    const result = await this.db.query(`
      SELECT id, first_name, last_name, birth_date, created_at, updated_at
      FROM persons
      WHERE first_name = $1 AND last_name = $2
    `, [firstName, lastName]);
    
    return result.rows[0] || null;
  }
  
  /**
   * Upsert person (insert or update if exists)
   */
  async upsert(person) {
    const existing = await this.findByName(person.firstName, person.lastName);
    
    if (existing) {
      // Update birth_date if provided and different
      if (person.birthDate && person.birthDate !== existing.birth_date) {
        await this.db.query(`
          UPDATE persons SET
            birth_date = $1,
            updated_at = CURRENT_TIMESTAMP
          WHERE id = $2
        `, [person.birthDate, existing.id]);
      }
      
      return { id: existing.id, inserted: false };
    }
    
    // Insert new
    const result = await this.db.query(`
      INSERT INTO persons (first_name, last_name, birth_date)
      VALUES ($1, $2, $3)
      RETURNING id
    `, [person.firstName, person.lastName, person.birthDate || null]);
    
    return { id: result.rows[0].id, inserted: true };
  }
}

module.exports = PersonRepository;
