const crypto = require('crypto');

/**
 * ID Generator Service
 * Provides consistent UUID generation across all scrapers
 */
class IdGenerator {
  /**
   * Generate a deterministic UUID from a seed string
   * Same seed always produces same UUID (useful for idempotent imports)
   */
  static deterministicUUID(seed, namespace = '00000000-0000-0000-0000') {
    const hash = crypto.createHash('md5').update(seed).digest('hex');
    
    // Format as UUID v4
    const p1 = hash.substring(0, 8);
    const p2 = hash.substring(8, 12);
    const p3 = '4' + hash.substring(13, 16); // Version 4
    const p4 = '8' + hash.substring(17, 20); // Variant 10xx
    const p5 = hash.substring(20, 32);
    
    return `${p1}-${p2}-${p3}-${p4}-${p5}`;
  }

  /**
   * Generate a deterministic UUID with a namespace prefix
   */
  static namespacedUUID(namespace, seed) {
    return this.deterministicUUID(`${namespace}:${seed}`);
  }

  /**
   * Generate a random UUID (non-deterministic)
   */
  static randomUUID() {
    return crypto.randomUUID();
  }

  /**
   * Generate UUID from components (league, team, etc.)
   */
  static fromComponents(...parts) {
    return this.deterministicUUID(parts.filter(p => p).join(':'));
  }
}

module.exports = IdGenerator;
