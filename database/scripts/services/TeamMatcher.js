/**
 * TeamMatcher - Matches scraped team names to known teams using aliases
 * 
 * Purpose:
 * - Load teams and aliases from registry (pre-populated from SQL files)
 * - Match scraped names against known teams using exact match, aliases, and normalization
 * - Prevent dynamic team creation - all teams must exist in static SQL files
 */
class TeamMatcher {
    constructor(registry, logger) {
        this.registry = registry;
        this.logger = logger || console;
        
        // Lookup caches
        this.teamsByExactName = new Map();      // exact name → team
        this.teamsByNormalizedName = new Map(); // normalized name → team
        this.aliasesByName = new Map();         // alias name → team_id
        
        // Tracking for enrichment mode
        this.unmatchedTeams = new Map();        // scraped name → count
        this.matchedTeams = new Map();          // team_id → count
        
        this.initialized = false;
    }
    
    /**
     * Initialize matcher by building lookup caches from registry
     */
    initialize() {
        if (this.initialized) return;
        
        this.logger.log('\n🔍 Initializing TeamMatcher...');
        
        // Build team lookup caches
        const teams = this.registry.getAllTeams();
        for (const team of teams) {
            // Exact name lookup
            this.teamsByExactName.set(team.name, team);
            
            // Normalized name lookup
            const normalized = this.normalizeTeamName(team.name);
            if (!this.teamsByNormalizedName.has(normalized)) {
                this.teamsByNormalizedName.set(normalized, team);
            }
        }
        
        // Build alias lookup cache (would load from team_aliases table in real implementation)
        // For now, we'll generate common variations automatically
        for (const team of teams) {
            const aliases = this.generateCommonAliases(team.name);
            for (const alias of aliases) {
                if (!this.aliasesByName.has(alias)) {
                    this.aliasesByName.set(alias, team.id);
                }
            }
        }
        
        this.logger.log(`   ✓ Loaded ${teams.length} teams with ${this.aliasesByName.size} aliases`);
        this.initialized = true;
    }
    
    /**
     * Find team by scraped name
     * 
     * @param {string} scrapedName - Team name from external source
     * @param {number} sourceSystemId - Source system ID (optional, for better matching)
     * @param {boolean} trackStats - Whether to track match/unmatch stats (default: true)
     * @returns {Object|null} Team object or null if not found
     */
    findTeamByName(scrapedName, sourceSystemId = null, trackStats = true) {
        if (!this.initialized) {
            this.initialize();
        }
        
        if (!scrapedName || typeof scrapedName !== 'string') {
            return null;
        }
        
        const trimmed = scrapedName.trim();
        
        // 1. Try exact match (case-sensitive)
        let team = this.teamsByExactName.get(trimmed);
        if (team && (!sourceSystemId || team.source_system_id === sourceSystemId)) {
            if (trackStats) this.trackMatch(team);
            return team;
        }
        
        // 2. Try exact match (case-insensitive)
        for (const [name, t] of this.teamsByExactName) {
            if (name.toLowerCase() === trimmed.toLowerCase()) {
                if (!sourceSystemId || t.source_system_id === sourceSystemId) {
                    if (trackStats) this.trackMatch(t);
                    return t;
                }
            }
        }
        
        // 3. Try alias lookup
        const teamIdFromAlias = this.aliasesByName.get(trimmed.toLowerCase());
        if (teamIdFromAlias) {
            team = this.registry.getTeamById(teamIdFromAlias);
            if (team && (!sourceSystemId || team.source_system_id === sourceSystemId)) {
                if (trackStats) this.trackMatch(team);
                return team;
            }
        }
        
        // 4. Try normalized match
        const normalized = this.normalizeTeamName(trimmed);
        team = this.teamsByNormalizedName.get(normalized);
        if (team && (!sourceSystemId || team.source_system_id === sourceSystemId)) {
            if (trackStats) this.trackMatch(team);
            return team;
        }
        
        // 5. Try fuzzy match on normalized variants
        const variants = this.generateTeamNameVariants(trimmed);
        for (const variant of variants) {
            // Check aliases
            const teamIdFromVariant = this.aliasesByName.get(variant);
            if (teamIdFromVariant) {
                team = this.registry.getTeamById(teamIdFromVariant);
                if (team && (!sourceSystemId || team.source_system_id === sourceSystemId)) {
                    if (trackStats) this.trackMatch(team);
                    return team;
                }
            }
            
            // Check normalized names
            team = this.teamsByNormalizedName.get(variant);
            if (team && (!sourceSystemId || team.source_system_id === sourceSystemId)) {
                if (trackStats) this.trackMatch(team);
                return team;
            }
        }
        
        // No match found - track unmatched
        if (trackStats) {
            this.trackUnmatched(trimmed);
        }
        
        return null;
    }
    
    /**
     * Track successful team match (for stats)
     */
    trackMatch(team) {
        const count = this.matchedTeams.get(team.id) || 0;
        this.matchedTeams.set(team.id, count + 1);
    }
    
    /**
     * Track unmatched team (for stats)
     */
    trackUnmatched(scrapedName) {
        const count = this.unmatchedTeams.get(scrapedName) || 0;
        this.unmatchedTeams.set(scrapedName, count + 1);
    }
    
    /**
     * Normalize team name for matching
     * Removes common suffixes, standardizes spacing, lowercases
     * 
     * @param {string} name - Team name
     * @returns {string} Normalized name
     */
    normalizeTeamName(name) {
        if (!name) return '';
        
        let normalized = name.toLowerCase().trim();
        
        // Remove common suffixes
        normalized = normalized.replace(/\s+(fc|sc|united|city|town|club|soccer|football)$/gi, '');
        
        // Remove punctuation
        normalized = normalized.replace(/[^\w\s]/g, '');
        
        // Normalize whitespace
        normalized = normalized.replace(/\s+/g, ' ').trim();
        
        return normalized;
    }
    
    /**
     * Generate common name variants for matching
     * 
     * @param {string} name - Team name
     * @returns {Array<string>} Array of name variants
     */
    generateTeamNameVariants(name) {
        if (!name) return [];
        
        const lower = name.toLowerCase().trim();
        const variants = new Set([lower]);
        
        // Remove all whitespace
        variants.add(lower.replace(/\s+/g, ''));
        
        // Remove FC/SC variations
        if (lower.includes(' fc') || lower.includes(' f.c.')) {
            variants.add(lower.replace(/\s*f\.?c\.?\s*/g, ' ').trim());
            variants.add(lower.replace(/\s*f\.?c\.?$/g, '').trim());
        }
        
        if (lower.includes(' sc') || lower.includes(' s.c.')) {
            variants.add(lower.replace(/\s*s\.?c\.?\s*/g, ' ').trim());
            variants.add(lower.replace(/\s*s\.?c\.?$/g, '').trim());
        }
        
        // Handle United
        if (lower.endsWith(' united')) {
            variants.add(lower.replace(/\s+united$/g, '').trim());
        }
        
        // Handle Roman numerals (II, III, IV, etc)
        variants.add(lower.replace(/\s+i+$/g, '').trim());
        variants.add(lower.replace(/\s+ii$/g, ' 2'));
        variants.add(lower.replace(/\s+iii$/g, ' 3'));
        variants.add(lower.replace(/\s+2$/g, ' ii'));
        variants.add(lower.replace(/\s+3$/g, ' iii'));
        
        // Remove punctuation
        variants.add(lower.replace(/[^\w\s]/g, '').trim());
        
        // Clean up whitespace in all variants
        const cleaned = new Set();
        for (const v of variants) {
            const clean = v.replace(/\s+/g, ' ').trim();
            if (clean.length > 0) {
                cleaned.add(clean);
            }
        }
        
        return Array.from(cleaned);
    }
    
    /**
     * Generate common aliases for a team name
     * Used when populating team_aliases table
     * 
     * @param {string} name - Team name
     * @returns {Array<string>} Array of common aliases
     */
    generateCommonAliases(name) {
        const aliases = new Set();
        const variants = this.generateTeamNameVariants(name);
        
        for (const variant of variants) {
            aliases.add(variant);
        }
        
        // Add specific patterns
        const lower = name.toLowerCase().trim();
        
        // "Philadelphia SC" → "Philly SC", "Philadelphia"
        if (lower.includes('philadelphia')) {
            aliases.add(lower.replace('philadelphia', 'philly'));
            if (lower.includes('sc')) {
                aliases.add('philly sc');
                aliases.add('philadelphia');
            }
        }
        
        // "Lighthouse" → "Lighthouse 1893", "1893 SC"
        if (lower.includes('lighthouse')) {
            aliases.add('lighthouse');
            aliases.add('lighthouse 1893');
            aliases.add('lighthouse 1893 sc');
            aliases.add('1893 sc');
        }
        
        return Array.from(aliases);
    }
    
    /**
     * Report unmatched teams for discovery mode
     * 
     * @param {Array<string>} scrapedTeamNames - Team names found during scraping
     * @param {number} sourceSystemId - Source system ID
     * @returns {Array<Object>} Array of unmatched teams with suggestions
     */
    reportUnmatched(scrapedTeamNames, sourceSystemId) {
        const unmatched = [];
        
        for (const scrapedName of scrapedTeamNames) {
            const match = this.findTeamByName(scrapedName, sourceSystemId);
            if (!match) {
                // Find potential matches (without source system filter)
                const potentialMatches = [];
                const normalized = this.normalizeTeamName(scrapedName);
                
                for (const [knownNorm, team] of this.teamsByNormalizedName) {
                    if (this.calculateSimilarity(normalized, knownNorm) > 0.7) {
                        potentialMatches.push(team.name);
                    }
                }
                
                unmatched.push({
                    scraped_name: scrapedName,
                    suggestions: potentialMatches.slice(0, 3)
                });
            }
        }
        
        return unmatched;
    
    /**
     * Print summary of team matching statistics
     * Useful at end of scraping to see unmatched teams
     */
    printSummary() {
        if (this.unmatchedTeams.size === 0 && this.matchedTeams.size === 0) {
            return; // No stats to show
        }
        
        this.logger.log('\n' + '='.repeat(80));
        this.logger.log('TEAM MATCHING SUMMARY');
        this.logger.log('='.repeat(80));
        
        // Matched teams
        if (this.matchedTeams.size > 0) {
            this.logger.log(`\n✅ Matched ${this.matchedTeams.size} unique teams:`);
            const sortedMatches = Array.from(this.matchedTeams.entries())
                .sort((a, b) => b[1] - a[1]) // Sort by count descending
                .slice(0, 10); // Show top 10
            
            for (const [teamId, count] of sortedMatches) {
                const team = this.registry.getTeamById(teamId);
                if (team) {
                    this.logger.log(`   ${team.name} (${count} references)`);
                }
            }
            
            if (this.matchedTeams.size > 10) {
                this.logger.log(`   ... and ${this.matchedTeams.size - 10} more`);
            }
        }
        
        // Unmatched teams
        if (this.unmatchedTeams.size > 0) {
            this.logger.log(`\n❌ UNMATCHED TEAMS (${this.unmatchedTeams.size}):`);
            this.logger.log('   These teams were found during scraping but not in static SQL files.');
            this.logger.log('   Data for these teams was SKIPPED.\n');
            
            const sortedUnmatched = Array.from(this.unmatchedTeams.entries())
                .sort((a, b) => b[1] - a[1]); // Sort by count descending
            
            for (const [scrapedName, count] of sortedUnmatched) {
                this.logger.log(`   • "${scrapedName}" (${count} occurrences)`);
                
                // Find potential matches
                const suggestions = this.findSimilarTeams(scrapedName);
                if (suggestions.length > 0) {
                    this.logger.log(`     Suggestions: ${suggestions.join(', ')}`);
                }
            }
            
            this.logger.log('\n📝 NEXT STEPS:');
            this.logger.log('   1. Run discovery mode to find new teams:');
            this.logger.log('      ./dev.sh --casa --discover  (or --apsl)');
            this.logger.log('   2. Manually add teams to database/data/022-teams.sql');
            this.logger.log('   3. Add aliases to database/data/023-team-aliases.sql');
            this.logger.log('   4. Rebuild database: ./dev.sh');
        }
        
        this.logger.log('='.repeat(80) + '\n');
    }
    
    /**
     * Find similar team names for suggestions
     */
    findSimilarTeams(scrapedName) {
        const suggestions = [];
        const normalized = this.normalizeTeamName(scrapedName);
        
        for (const [knownName, team] of this.teamsByExactName) {
            const knownNorm = this.normalizeTeamName(knownName);
            const similarity = this.calculateSimilarity(normalized, knownNorm);
            
            if (similarity > 0.6) {
                suggestions.push(knownName);
            }
            
            if (suggestions.length >= 3) break; // Limit to 3 suggestions
        }
        
        return suggestions;
    }
    
    /**
     * Reset statistics (useful between scraping runs)
     */
    resetStats() {
        this.unmatchedTeams.clear();
        this.matchedTeams.clear();
    }
    }
    
    /**
     * Calculate string similarity (simple Levenshtein-like)
     * 
     * @param {string} s1 - First string
     * @param {string} s2 - Second string
     * @returns {number} Similarity score (0-1)
     */
    calculateSimilarity(s1, s2) {
        const longer = s1.length > s2.length ? s1 : s2;
        const shorter = s1.length > s2.length ? s2 : s1;
        
        if (longer.length === 0) return 1.0;
        
        // Simple containment check
        if (longer.includes(shorter)) return 0.8;
        if (shorter.includes(longer)) return 0.8;
        
        // Count matching characters
        let matches = 0;
        for (let i = 0; i < shorter.length; i++) {
            if (longer.includes(shorter[i])) matches++;
        }
        
        return matches / longer.length;
    }
}

module.exports = TeamMatcher;
