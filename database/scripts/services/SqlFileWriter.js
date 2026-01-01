/**
 * SqlFileWriter - Generates SQL INSERT statements for database loading
 * 
 * Purpose:
 * - Generate properly formatted SQL files
 * - Handle ON CONFLICT for upserts
 * - Support multiple table types
 */
class SqlFileWriter {
    constructor(logger) {
        this.logger = logger || console;
    }
    
    /**
     * Generate SQL INSERT statement for clubs
     * 
     * @param {Array<Object>} clubs - Array of club entities
     * @returns {string} SQL INSERT statement
     */
    generateClubsSQL(clubs) {
        if (!clubs || clubs.length === 0) {
            return '-- No clubs to insert\n';
        }
        
        const values = clubs.map(club => {
            const displayName = this.escape(club.display_name);
            const slug = this.escape(club.slug);
            const sourceSystemId = club.source_system_id || 'NULL';
            const isActive = club.is_active !== false ? 'true' : 'false';
            
            return `  (${club.id}, ${displayName}, ${slug}, ${sourceSystemId}, ${isActive})`;
        });
        
        return `-- Clubs
INSERT INTO clubs (id, display_name, slug, source_system_id, is_active)
VALUES
${values.join(',\n')}
ON CONFLICT (id) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  slug = EXCLUDED.slug,
  source_system_id = EXCLUDED.source_system_id,
  is_active = EXCLUDED.is_active;
`;
    }
    
    /**
     * Generate SQL INSERT statement for sport_divisions
     * 
     * @param {Array<Object>} sportDivisions - Array of sport_division entities
     * @returns {string} SQL INSERT statement
     */
    generateSportDivisionsSQL(sportDivisions) {
        if (!sportDivisions || sportDivisions.length === 0) {
            return '-- No sport_divisions to insert\n';
        }
        
        const values = sportDivisions.map(sd => {
            const clubId = sd.club_id;
            const displayName = this.escape(sd.display_name);
            const sport = this.escape(sd.sport || 'soccer');
            const isActive = sd.is_active !== false ? 'true' : 'false';
            
            return `  (${sd.id}, ${clubId}, ${displayName}, ${sport}, ${isActive})`;
        });
        
        return `-- Sport Divisions
INSERT INTO sport_divisions (id, club_id, display_name, sport, is_active)
VALUES
${values.join(',\n')}
ON CONFLICT (id) DO UPDATE SET
  club_id = EXCLUDED.club_id,
  display_name = EXCLUDED.display_name,
  sport = EXCLUDED.sport,
  is_active = EXCLUDED.is_active;
`;
    }
    
    /**
     * Generate SQL INSERT statement for teams
     * 
     * @param {Array<Object>} teams - Array of team entities
     * @returns {string} SQL INSERT statement
     */
    generateTeamsSQL(teams) {
        if (!teams || teams.length === 0) {
            return '-- No teams to insert\n';
        }
        
        const values = teams.map(team => {
            const sportDivisionId = team.sport_division_id || 'NULL';
            const name = this.escape(team.name);
            const city = team.city ? this.escape(team.city) : 'NULL';
            const logoUrl = team.logo_url ? this.escape(team.logo_url) : 'NULL';
            const isActive = team.is_active === false ? 'NULL' : 'true';
            const sourceSystemId = team.source_system_id || 'NULL';
            const externalId = this.escape(team.external_id);
            
            return `  (${team.id}, ${sportDivisionId}, ${name}, ${city}, ${logoUrl}, ${isActive}, ${sourceSystemId}, ${externalId})`;
        });
        
        return `-- Teams
INSERT INTO teams (id, sport_division_id, name, city, logo_url, is_active, source_system_id, external_id)
VALUES
${values.join(',\n')}
ON CONFLICT (id) DO UPDATE SET
  sport_division_id = EXCLUDED.sport_division_id,
  name = EXCLUDED.name,
  city = EXCLUDED.city,
  logo_url = EXCLUDED.logo_url,
  is_active = EXCLUDED.is_active,
  source_system_id = EXCLUDED.source_system_id,
  external_id = EXCLUDED.external_id;
`;
    }
    
    /**
     * Escape SQL string values
     * 
     * @param {string} value - Value to escape
     * @returns {string} Escaped value with quotes or NULL
     */
    escape(value) {
        if (value === null || value === undefined) {
            return 'NULL';
        }
        
        // Convert to string and escape single quotes
        const str = String(value).replace(/'/g, "''");
        return `'${str}'`;
    }
    
    /**
     * Write SQL to file
     * 
     * @param {string} filePath - Path to write file
     * @param {string} sql - SQL content
     */
    async writeFile(filePath, sql) {
        const fs = require('fs').promises;
        await fs.writeFile(filePath, sql, 'utf8');
        this.logger.log(`✓ ${filePath}: ${sql.split('\n').filter(line => line.trim().startsWith('(')).length} records`);
    }
}

module.exports = SqlFileWriter;
