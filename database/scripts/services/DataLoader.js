const fs = require('fs');
const path = require('path');

/**
 * DataLoader - Loads existing data from SQL files into DataRegistry
 * 
 * Purpose:
 * - Parse existing SQL files before scrapers run
 * - Populate DataRegistry with existing clubs, sport_divisions, teams
 * - Enable matching against previously scraped data
 */
class DataLoader {
    constructor(registry, logger) {
        this.registry = registry;
        this.logger = logger || console;
        this.dataDir = path.join(__dirname, '../../data');
    }

    /**
     * Load all existing data from SQL files
     */
    loadAllExistingData() {
        this.logger.log(`\n📥 Loading existing data from SQL files...`);
        
        this.loadExistingClubs();
        this.loadExistingSportDivisions();
        
        this.logger.log(`   ✓ Loaded ${this.registry.clubs.size} clubs, ${this.registry.sportDivisions.size} sport_divisions`);
    }

    /**
     * Load clubs from SQL files
     */
    loadExistingClubs() {
        const clubFiles = [
            '025-clubs.sql',      // Base clubs (APSL + manually added) - LOAD FIRST
            '025m-clubs.sql'      // Manual clubs
            // NOTE: Don't load scraper-generated files (025-casa-clubs.sql, etc.) 
            // because we want to regenerate those
        ];

        for (const filename of clubFiles) {
            const filePath = path.join(this.dataDir, filename);
            if (fs.existsSync(filePath)) {
                this._parseClubsFromSql(filePath);
            }
        }
    }

    /**
     * Load sport_divisions from SQL files
     */
    loadExistingSportDivisions() {
        const sportDivFiles = [
            '027-sport-divisions-base.sql'      // Base sport_divisions (APSL clubs)
            // NOTE: Don't load scraper-generated files (027-casa-sport-divisions.sql, etc.)
            // because we want to regenerate those
        ];

        for (const filename of sportDivFiles) {
            const filePath = path.join(this.dataDir, filename);
            if (fs.existsSync(filePath)) {
                this._parseSportDivisionsFromSql(filePath);
            }
        }
    }

    /**
     * Parse clubs from SQL INSERT statements
     */
    _parseClubsFromSql(filePath) {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Match VALUES lines: (id, 'display_name', 'slug', source_system_id, 'external_id'|NULL, is_active)
        const valueRegex = /\((\d+),\s*'([^']+)',\s*'([^']+)',\s*(\d+),\s*(?:'([^']*)'|NULL),\s*(true|false)\)/g;
        let match;
        let count = 0;
        
        while ((match = valueRegex.exec(content)) !== null) {
            const [, id, displayName, slug, sourceSystemId, externalId, isActive] = match;
            
            const club = {
                id: parseInt(id),
                display_name: displayName,
                slug: slug,
                source_system_id: parseInt(sourceSystemId),
                external_id: externalId || null,
                is_active: isActive === 'true'
            };
            
            this.registry.addClub(club);
            count++;
        }
        
        if (count > 0) {
            this.logger.log(`   ✓ Loaded ${count} clubs from ${path.basename(filePath)}`);
        }
    }

    /**
     * Parse sport_divisions from SQL INSERT statements
     */
    _parseSportDivisionsFromSql(filePath) {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Match VALUES lines: (id, club_id, 'display_name', 'sport', is_active)
        const valueRegex = /\((\d+),\s*(\d+),\s*'([^']+)',\s*'([^']+)',\s*(true|false)\)/g;
        let match;
        let count = 0;
        
        while ((match = valueRegex.exec(content)) !== null) {
            const [, id, clubId, displayName, sport, isActive] = match;
            
            const sportDiv = {
                id: parseInt(id),
                club_id: parseInt(clubId),
                display_name: displayName,
                sport: sport,
                is_active: isActive === 'true'
            };
            
            this.registry.addSportDivision(sportDiv);
            count++;
        }
        
        if (count > 0) {
            this.logger.log(`   ✓ Loaded ${count} sport_divisions from ${path.basename(filePath)}`);
        }
    }
}

module.exports = DataLoader;
