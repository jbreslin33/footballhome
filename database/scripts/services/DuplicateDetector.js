/**
 * Duplicate Detection Service
 * Tracks entities to prevent duplicate insertions
 */
class DuplicateDetector {
  constructor() {
    this.seen = new Map();
  }

  /**
   * Check if an entity is a duplicate based on specified key fields
   * @param {string} entityType - Type of entity (e.g., 'player', 'team')
   * @param {object} entity - The entity to check
   * @param {string[]} keyFields - Fields that uniquely identify the entity
   * @returns {boolean} - True if duplicate, false if new
   */
  isDuplicate(entityType, entity, keyFields) {
    const key = this.generateKey(entityType, entity, keyFields);
    
    if (this.seen.has(key)) {
      return true;
    }
    
    this.seen.set(key, entity);
    return false;
  }

  /**
   * Get existing entity if it's a duplicate
   * @param {string} entityType
   * @param {object} entity
   * @param {string[]} keyFields
   * @returns {object|null} - Existing entity or null
   */
  getExisting(entityType, entity, keyFields) {
    const key = this.generateKey(entityType, entity, keyFields);
    return this.seen.get(key) || null;
  }

  /**
   * Mark an entity as seen
   */
  markSeen(entityType, entity, keyFields) {
    const key = this.generateKey(entityType, entity, keyFields);
    this.seen.set(key, entity);
  }

  /**
   * Generate a unique key from entity and fields
   */
  generateKey(entityType, entity, keyFields) {
    const values = keyFields.map(field => {
      const value = entity[field];
      return value !== null && value !== undefined ? 
        String(value).toLowerCase().trim() : 
        '';
    });
    
    return `${entityType}:${values.join('|')}`;
  }

  /**
   * Clear all tracked entities
   */
  clear() {
    this.seen.clear();
  }

  /**
   * Get statistics
   */
  getStats() {
    return {
      totalSeen: this.seen.size,
      byType: this.getCountsByType()
    };
  }

  getCountsByType() {
    const counts = {};
    for (const key of this.seen.keys()) {
      const type = key.split(':')[0];
      counts[type] = (counts[type] || 0) + 1;
    }
    return counts;
  }
}

module.exports = DuplicateDetector;
