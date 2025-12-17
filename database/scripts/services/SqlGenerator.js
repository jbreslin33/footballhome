const fs = require('fs');
const path = require('path');

/**
 * SQL Generator Service
 * Generates SQL output files from entity collections
 */
class SqlGenerator {
  constructor(config = {}) {
    this.outputDir = config.outputDir || path.join(__dirname, '../../data');
    this.useInserts = config.useInserts || false; // Default to COPY format
  }

  /**
   * Generate SQL file from entities
   * @param {string} filename - Output filename (e.g., '03-leagues-apsl.sql')
   * @param {Array} entities - Array of entity objects with toSQL() method
   * @param {object} options - Generation options
   */
  async generate(filename, entities, options = {}) {
    const filepath = path.join(this.outputDir, filename);
    const lines = [];

    // Header
    lines.push(`-- ${options.title || filename}`);
    lines.push(`-- Generated at: ${new Date().toISOString()}`);
    if (options.description) {
      lines.push(`-- ${options.description}`);
    }
    lines.push('');

    // Generate SQL for each entity
    if (options.customSQL) {
      // Use custom SQL generator function
      lines.push(options.customSQL(entities));
    } else if (this.useInserts || options.useInserts) {
      // Traditional INSERT statements
      if (entities.length > 0 && options.tableName) {
        lines.push(...this.generateInsertStatements(options.tableName, entities, options));
      } else {
        // Fallback to entity.toSQL() if no table name specified (legacy behavior)
        for (const entity of entities) {
          if (entity.toSQL) {
            lines.push(entity.toSQL());
          }
        }
      }
    } else {
      // COPY format (more efficient for bulk imports)
      if (entities.length > 0 && options.tableName) {
        lines.push(...this.generateCopyFormat(options.tableName, entities, options));
      }
    }

    lines.push('');

    // Write to file
    await fs.promises.writeFile(filepath, lines.join('\n'), 'utf8');
    
    return {
      filepath,
      count: entities.length,
      size: Buffer.byteLength(lines.join('\n'), 'utf8')
    };
  }

  /**
   * Generate INSERT statements with ON CONFLICT
   */
  generateInsertStatements(tableName, entities, options = {}) {
    const lines = [];
    const columns = options.columns || this.inferColumns(entities[0]);
    const conflictColumn = options.conflictColumn || 'id';

    // INSERT INTO statement
    lines.push(`INSERT INTO ${tableName} (${columns.join(', ')})`);
    lines.push('VALUES');

    // Generate VALUES rows
    const valueRows = entities.map(entity => {
      if (entity.toSQL) {
        return `  ${entity.toSQL()}`;
      }
      // Fallback: generate from entity properties
      const values = columns.map(col => SqlGenerator.escape(entity[col]));
      return `  (${values.join(', ')})`;
    });

    lines.push(valueRows.join(',\n'));

    // ON CONFLICT clause
    lines.push(`ON CONFLICT (${conflictColumn}) DO UPDATE SET`);
    const updateClauses = columns
      .filter(col => col !== conflictColumn && col !== 'created_at')
      .map(col => `  ${col} = EXCLUDED.${col}`);
    lines.push(updateClauses.join(',\n'));
    lines.push(';');
    lines.push('');

    return lines;
  }

  /**
   * Generate PostgreSQL COPY format
   */
  generateCopyFormat(tableName, entities, options = {}) {
    const lines = [];
    const columns = options.columns || this.inferColumns(entities[0]);

    // COPY command
    lines.push(`COPY ${tableName} (${columns.join(', ')}) FROM stdin;`);

    // Data rows
    for (const entity of entities) {
      const values = columns.map(col => {
        const value = entity[col];
        return this.formatCopyValue(value);
      });
      lines.push(values.join('\t'));
    }

    // End marker
    lines.push('\\.');
    lines.push('');

    return lines;
  }

  /**
   * Format a value for PostgreSQL COPY format
   */
  formatCopyValue(value) {
    if (value === null || value === undefined) return '\\N';
    if (typeof value === 'boolean') return value ? 't' : 'f';
    if (typeof value === 'object') {
      return JSON.stringify(value)
        .replace(/\\/g, '\\\\')
        .replace(/\t/g, '\\t')
        .replace(/\n/g, '\\n')
        .replace(/\r/g, '\\r');
    }
    return String(value)
      .replace(/\\/g, '\\\\')
      .replace(/\t/g, '\\t')
      .replace(/\n/g, '\\n')
      .replace(/\r/g, '\\r');
  }

  /**
   * Infer columns from first entity
   */
  inferColumns(entity) {
    if (!entity) return [];
    return Object.keys(entity).filter(key => 
      !key.startsWith('_') && typeof entity[key] !== 'function'
    );
  }

  /**
   * Generate multiple SQL files from data maps
   */
  async generateMultiple(filesConfig) {
    const results = [];
    
    for (const config of filesConfig) {
      const entities = Array.from(config.data.values());
      if (entities.length > 0) {
        const result = await this.generate(
          config.filename,
          entities,
          config.options || {}
        );
        results.push(result);
      }
    }

    return results;
  }

  /**
   * SQL escape helper (for INSERT statements)
   */
  static escape(value) {
    if (value === null || value === undefined) return 'NULL';
    if (typeof value === 'boolean') return value ? 'true' : 'false';
    if (typeof value === 'number') return value;
    if (typeof value === 'object') return `'${JSON.stringify(value).replace(/'/g, "''")}'`;
    return `'${String(value).replace(/'/g, "''")}'`;
  }
}

module.exports = SqlGenerator;
