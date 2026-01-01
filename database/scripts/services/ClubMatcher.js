const fs = require('fs');
const path = require('path');

/**
 * ClubMatcher - Matches team names to existing clubs using normalized name matching
 * 
 * Responsibilities:
 * - Load existing clubs from database SQL files (APSL clubs from 020a-*.sql, manual clubs, etc.)
 * - Normalize team/club names for fuzzy matching
 * - Match scraped teams to existing clubs by normalized name
 * - Track matches and unmatched teams
 */
class ClubMatcher {
    constructor() {
        this.existingClubs = new Map(); // slug -> club object
        this.clubsByNormalizedName = new Map(); // normalized name -> club object
    }

    /**
     * Load existing clubs from database SQL files
     */
    loadExistingClubs() {
        const dataDir = path.join(__dirname, '../../data');
        const clubFiles = [
            '020a-apsl-clubs.sql',
            '020m-clubs-manual.sql',
            '014-casa-clubs.sql'
        ];

        for (const filename of clubFiles) {
            const filePath = path.join(dataDir, filename);
            if (fs.existsSync(filePath)) {
                this._parseClubsFromSql(filePath);
            }
        }

        console.log(`   Loaded ${this.existingClubs.size} existing clubs for matching`);
    }

    /**
     * Parse clubs from SQL INSERT statements
     */
    _parseClubsFromSql(filePath) {
        const content = fs.readFileSync(filePath, 'utf8');
        
        // Match VALUES lines: (id, 'display_name', 'slug', ...)
        const valueRegex = /\((\d+),\s*'([^']+)',\s*'([^']+)',/g;
        let match;
        
        while ((match = valueRegex.exec(content)) !== null) {
            const [, id, displayName, slug] = match;
            
            const club = {
                id: parseInt(id),
                display_name: displayName,
                slug: slug,
                source: path.basename(filePath)
            };
            
            this.existingClubs.set(slug, club);
            
            // Index by normalized name for matching
            const normalized = this.normalizeClubName(displayName);
            this.clubsByNormalizedName.set(normalized, club);
            
            // Also index common variations
            const variations = this.generateNameVariations(displayName);
            for (const variant of variations) {
                if (!this.clubsByNormalizedName.has(variant)) {
                    this.clubsByNormalizedName.set(variant, club);
                }
            }
        }
    }

    /**
     * Normalize club name for matching
     * "Lighthouse 1893 SC" -> "lighthouse"
     * "Oaklyn United FC II" -> "oaklyn"
     */
    normalizeClubName(name) {
        let normalized = name.toLowerCase();
        
        // Remove common suffixes
        normalized = normalized
            .replace(/\s+(fc|sc|united|club|soccer|1893|ii|iii|iv|boys|old timers|reserves|majors|minors)\b/gi, '')
            .replace(/\s+\d+/g, '') // Remove numbers
            .replace(/[^a-z\s]/g, '') // Remove punctuation
            .trim()
            .replace(/\s+/g, ''); // Remove spaces
        
        return normalized;
    }

    /**
     * Generate name variations for better matching
     */
    generateNameVariations(name) {
        const variations = new Set();
        const lower = name.toLowerCase();
        
        // Base normalized
        variations.add(this.normalizeClubName(name));
        
        // Without suffixes but keep spaces
        let working = lower
            .replace(/\s+(fc|sc|united|club|soccer)\b/gi, '')
            .trim();
        variations.add(working.replace(/\s+/g, ''));
        
        // Just first word
        const firstWord = lower.split(/\s+/)[0];
        if (firstWord.length > 3) { // Only if meaningful
            variations.add(firstWord);
        }
        
        // Without numbers
        variations.add(lower.replace(/\d+/g, '').trim().replace(/\s+/g, ''));
        
        return Array.from(variations).filter(v => v.length > 0);
    }

    /**
     * Find matching club for a team name
     * @returns {object|null} Matching club or null
     */
    findMatchingClub(teamName) {
        const normalized = this.normalizeClubName(teamName);
        
        // Direct match
        if (this.clubsByNormalizedName.has(normalized)) {
            return this.clubsByNormalizedName.get(normalized);
        }
        
        // Try variations
        const variations = this.generateNameVariations(teamName);
        for (const variant of variations) {
            if (this.clubsByNormalizedName.has(variant)) {
                return this.clubsByNormalizedName.get(variant);
            }
        }
        
        return null;
    }

    /**
     * Get all existing club IDs
     */
    getAllClubIds() {
        return Array.from(this.existingClubs.values()).map(c => c.id);
    }

    /**
     * Get next available club ID
     */
    getNextClubId() {
        const existingIds = this.getAllClubIds();
        return existingIds.length > 0 ? Math.max(...existingIds) + 1 : 1;
    }
}

module.exports = ClubMatcher;
