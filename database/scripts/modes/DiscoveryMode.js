/**
 * DiscoveryMode - Phase 1 scraping to discover league structure
 * 
 * Purpose:
 * - Scrape conferences, divisions, teams from external source
 * - Output structure for manual review
 * - Generate template SQL files
 * - Do NOT write to database
 * 
 * Usage:
 * const discovery = new DiscoveryMode(scraper);
 * await discovery.discover();
 * discovery.outputForReview();
 */
class DiscoveryMode {
    constructor(scraper) {
        this.scraper = scraper;
        this.discovered = {
            conferences: [],
            divisions: [],
            teams: [],
            suggestedAliases: new Map()
        };
    }
    
    /**
     * Run discovery scraping
     */
    async discover() {
        this.scraper.log('\n🔍 DISCOVERY MODE - Analyzing league structure...');
        this.scraper.log('   This will NOT write to the database.');
        this.scraper.log('   Review output and create static SQL files manually.\n');
        
        // Let the scraper do its normal initialization and fetch
        await this.scraper.initialize();
        await this.scraper.fetchData();
        
        // Extract discovered structure
        this.extractStructure();
    }
    
    /**
     * Extract structure from scraper's data
     */
    extractStructure() {
        // Extract conferences
        for (const [id, conf] of this.scraper.data.conferences || new Map()) {
            this.discovered.conferences.push({
                name: conf.name,
                abbreviation: conf.abbreviation,
                external_id: conf.external_id
            });
        }
        
        // Extract divisions
        for (const [id, div] of this.scraper.data.divisions || new Map()) {
            const conf = this.scraper.data.conferences.get(div.conference_id);
            this.discovered.divisions.push({
                name: div.name,
                conference: conf ? conf.name : 'Unknown',
                skill_level: div.skill_level,
                skill_label: div.skill_label,
                external_id: div.external_id
            });
        }
        
        // Extract teams
        for (const [id, team] of this.scraper.data.teams || new Map()) {
            this.discovered.teams.push({
                name: team.name,
                city: team.city,
                external_id: team.external_id,
                source_system_id: team.source_system_id
            });
            
            // Generate suggested aliases
            const aliases = this.generateSuggestedAliases(team.name);
            this.suggestedAliases.set(team.name, aliases);
        }
    }
    
    /**
     * Generate suggested aliases for a team name
     */
    generateSuggestedAliases(teamName) {
        const aliases = new Set();
        const lower = teamName.toLowerCase().trim();
        
        // Add the original name
        aliases.add(teamName);
        
        // Remove FC/SC/United variations
        const withoutSuffix = lower.replace(/\s+(fc|sc|united|city|club)$/i, '').trim();
        if (withoutSuffix !== lower) {
            aliases.add(withoutSuffix);
        }
        
        // Philadelphia → Philly
        if (lower.includes('philadelphia')) {
            aliases.add(teamName.replace(/Philadelphia/gi, 'Philly'));
        }
        
        // Handle Roman numerals
        if (lower.includes(' ii')) {
            aliases.add(teamName.replace(/ II$/i, ' 2'));
        }
        if (lower.includes(' 2')) {
            aliases.add(teamName.replace(/ 2$/, ' II'));
        }
        
        return Array.from(aliases).filter(a => a !== teamName);
    }
    
    /**
     * Output discovered structure for review
     */
    outputForReview() {
        const sourceSystem = this.scraper.config.name || 'Unknown';
        
        console.log('\n' + '='.repeat(80));
        console.log(`DISCOVERY RESULTS: ${sourceSystem}`);
        console.log('='.repeat(80));
        
        // Conferences
        console.log('\n📍 CONFERENCES:');
        console.log('-'.repeat(80));
        for (const conf of this.discovered.conferences) {
            console.log(`  • ${conf.name} (${conf.abbreviation})`);
            console.log(`    External ID: ${conf.external_id}`);
        }
        
        // Divisions
        console.log('\n🏆 DIVISIONS:');
        console.log('-'.repeat(80));
        for (const div of this.discovered.divisions) {
            console.log(`  • ${div.conference} - ${div.name}`);
            console.log(`    Skill Level: ${div.skill_level} (${div.skill_label})`);
            console.log(`    External ID: ${div.external_id}`);
        }
        
        // Teams
        console.log('\n⚽ TEAMS:');
        console.log('-'.repeat(80));
        const sortedTeams = this.discovered.teams.sort((a, b) => a.name.localeCompare(b.name));
        for (const team of sortedTeams) {
            console.log(`  • ${team.name}`);
            if (team.city) console.log(`    City: ${team.city}`);
            console.log(`    External ID: ${team.external_id}`);
            
            const aliases = this.suggestedAliases.get(team.name);
            if (aliases && aliases.length > 0) {
                console.log(`    Suggested Aliases: ${aliases.join(', ')}`);
            }
        }
        
        // Summary
        console.log('\n' + '='.repeat(80));
        console.log('SUMMARY:');
        console.log(`  ${this.discovered.conferences.length} conferences`);
        console.log(`  ${this.discovered.divisions.length} divisions`);
        console.log(`  ${this.discovered.teams.length} teams`);
        console.log('='.repeat(80));
        
        // Next steps
        console.log('\n📝 NEXT STEPS:');
        console.log('  1. Review the structure above');
        console.log('  2. Create/update static SQL files:');
        console.log('     - database/data/020-clubs.sql');
        console.log('     - database/data/021-sport-divisions.sql');
        console.log('     - database/data/022-teams.sql');
        console.log('     - database/data/023-team-aliases.sql');
        console.log('  3. Run normal scraper mode to enrich with dynamic data');
        console.log('');
    }
    
    /**
     * Generate SQL template files
     */
    generateSqlTemplates() {
        const sourceSystemId = this.scraper.SOURCE_SYSTEM_ID || 1;
        const templates = {
            clubs: [],
            sportDivisions: [],
            teams: [],
            aliases: []
        };
        
        // Generate unique clubs from team names
        const clubs = new Set();
        for (const team of this.discovered.teams) {
            // Extract club name (remove suffixes like II, 2, etc)
            const clubName = team.name.replace(/\s+(II|2|III|3|B|Reserve)$/i, '').trim();
            clubs.add(clubName);
        }
        
        let clubId = 1;
        const clubMap = new Map();
        for (const clubName of Array.from(clubs).sort()) {
            const slug = clubName.toLowerCase().replace(/[^a-z0-9]+/g, '-');
            templates.clubs.push(
                `(${clubId}, '${clubName}', '${slug}', true, '${clubName} (${sourceSystemId})', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`
            );
            clubMap.set(clubName, clubId);
            clubId++;
        }
        
        // Generate sport divisions (one per club for now)
        let sportDivId = 1;
        const sportDivMap = new Map();
        for (const [clubName, cId] of clubMap) {
            templates.sportDivisions.push(
                `(${sportDivId}, ${cId}, '${clubName} Soccer', 'men', 'Open', true, ${sourceSystemId}, 'sport-div-${sportDivId}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)`
            );
            sportDivMap.set(clubName, sportDivId);
            sportDivId++;
        }
        
        // Generate teams
        let teamId = 1;
        for (const team of this.discovered.teams.sort((a, b) => a.name.localeCompare(b.name))) {
            const clubName = team.name.replace(/\s+(II|2|III|3|B|Reserve)$/i, '').trim();
            const sportDivisionId = sportDivMap.get(clubName) || 1;
            const city = team.city ? `'${team.city}'` : 'NULL';
            
            templates.teams.push(
                `(${teamId}, ${sportDivisionId}, '${team.name}', ${city}, NULL, ${sourceSystemId}, '${team.external_id}')`
            );
            
            // Generate aliases
            const aliases = this.suggestedAliases.get(team.name) || [];
            for (const alias of aliases) {
                templates.aliases.push(
                    `(${teamId}, '${alias}', 1, ${sourceSystemId})`  // 1 = common_name alias type
                );
            }
            
            teamId++;
        }
        
        return templates;
    }
    
    /**
     * Write SQL template files to disk
     */
    async writeSqlTemplates(outputDir) {
        const fs = require('fs').promises;
        const path = require('path');
        
        const templates = this.generateSqlTemplates();
        const sourceSystem = (this.scraper.config.name || 'unknown').toLowerCase();
        
        // Write clubs
        const clubsSql = `-- Clubs discovered from ${sourceSystem.toUpperCase()}
-- Review and merge with existing clubs in 020-clubs.sql

INSERT INTO clubs (id, display_name, slug, is_active, notes, created_at, updated_at) VALUES
${templates.clubs.join(',\n')}
ON CONFLICT (id) DO NOTHING;
`;
        await fs.writeFile(path.join(outputDir, `020-clubs-${sourceSystem}-discovered.sql`), clubsSql);
        
        // Write sport divisions
        const sportDivsSql = `-- Sport Divisions discovered from ${sourceSystem.toUpperCase()}
-- Review and merge with existing sport_divisions in 021-sport-divisions.sql

INSERT INTO sport_divisions (id, club_id, name, sex, age_label, is_active, source_system_id, external_id, created_at, updated_at) VALUES
${templates.sportDivisions.join(',\n')}
ON CONFLICT (id) DO NOTHING;
`;
        await fs.writeFile(path.join(outputDir, `021-sport-divisions-${sourceSystem}-discovered.sql`), sportDivsSql);
        
        // Write teams
        const teamsSql = `-- Teams discovered from ${sourceSystem.toUpperCase()}
-- Review and merge with existing teams in 022-teams.sql

INSERT INTO teams (id, sport_division_id, name, city, logo_url, source_system_id, external_id) VALUES
${templates.teams.join(',\n')}
ON CONFLICT (id) DO NOTHING;
`;
        await fs.writeFile(path.join(outputDir, `022-teams-${sourceSystem}-discovered.sql`), teamsSql);
        
        // Write aliases
        if (templates.aliases.length > 0) {
            const aliasesSql = `-- Team Aliases discovered from ${sourceSystem.toUpperCase()}
-- Review and merge with existing aliases in 023-team-aliases.sql

INSERT INTO team_aliases (team_id, alias_name, alias_type_id, source_system_id) VALUES
${templates.aliases.join(',\n')}
ON CONFLICT (team_id, alias_name) DO NOTHING;
`;
            await fs.writeFile(path.join(outputDir, `023-team-aliases-${sourceSystem}-discovered.sql`), aliasesSql);
        }
        
        console.log(`\n✓ SQL templates written to ${outputDir}/`);
        console.log(`  Review and merge with base SQL files.`);
    }
}

module.exports = DiscoveryMode;
