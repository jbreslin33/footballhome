#!/usr/bin/env node
/**
 * Generate SQL for CASA Select matches
 * Reads division-matches.json and creates 052-matches-casa.sql
 */

const fs = require('fs');
const path = require('path');

const MATCHES_JSON = path.join(__dirname, '../scraped-html/casa/division-matches.json');
const OUTPUT_SQL = path.join(__dirname, '../data/052-matches-casa.sql');

// Division mapping (from scrape-targets.json and database)
const DIVISION_MAP = {
  54: { name: 'Philadelphia Liga 1', external_id: '9090889' },
  55: { name: 'Philadelphia Liga 2', external_id: '9096430' },
  56: { name: 'Boston Liga 1', external_id: '9090891' },
  57: { name: 'Lancaster Liga 1', external_id: '9090893' }
};

function parseMatchDateTime(timeString) {
  // Example: "3:00 PM EST - 4:45 PM EST"
  // Extract start time only
  const startTime = timeString.split(' - ')[0].trim();
  
  // For now, use a default date in the 2025/2026 season
  // In production, this would come from actual match date data
  return {
    date: '2025-09-15',
    time: convertTo24Hour(startTime)
  };
}

function convertTo24Hour(timeStr) {
  // "3:00 PM EST" -> "15:00:00"
  const match = timeStr.match(/(\d+):(\d+)\s+(AM|PM)/);
  if (!match) return '12:00:00';
  
  let [_, hours, minutes, meridiem] = match;
  hours = parseInt(hours);
  
  if (meridiem === 'PM' && hours !== 12) hours += 12;
  if (meridiem === 'AM' && hours === 12) hours = 0;
  
  return `${hours.toString().padStart(2, '0')}:${minutes}:00`;
}

function parseScore(scoreStr) {
  // "3 - 6" -> { home: 3, away: 6 }
  if (!scoreStr || scoreStr === '-') return null;
  const parts = scoreStr.split('-').map(s => s.trim());
  if (parts.length !== 2) return null;
  return {
    home: parseInt(parts[0]) || 0,
    away: parseInt(parts[1]) || 0
  };
}

function getMatchTypeId(status) {
  // Map status to match_type_id
  // 1 = Training, 2 = Friendly, 3 = League, 4 = Tournament, 5 = Playoff
  return 3; // League match (default for CASA)
}

function generateMatchSQL() {
  const data = JSON.parse(fs.readFileSync(MATCHES_JSON, 'utf8'));
  
  let sql = `-- ============================================================================
-- 052-matches-casa.sql
-- CASA Select Matches (2025/2026 Season)
-- Generated: ${new Date().toISOString().split('T')[0]}
-- Source: Scraped from casasoccerleagues.com
-- ============================================================================
--
-- Total matches: ${data.total_matches}
-- Divisions: ${data.divisions.length}
--

`;

  let matchCount = 0;
  
  for (const division of data.divisions) {
    const divisionInfo = DIVISION_MAP[division.id];
    if (!divisionInfo) {
      console.warn(`Unknown division ${division.id}`);
      continue;
    }
    
    sql += `-- ${division.name} (Division ${division.id})\n`;
    sql += `-- Matches: ${division.matches.length}\n\n`;
    
    for (const match of division.matches) {
      const score = parseScore(match.score);
      const dateTime = parseMatchDateTime(match.time);
      
      // Note: Some teams in the match data may not exist in our database
      // (e.g., "Philadelphia Sierra Stars", "Phoenix Reserves", "Philly BlackStars")
      // These will need to be handled with conditional logic or added to teams
      
      sql += `-- ${match.home} vs ${match.away} (${match.status})\n`;
      sql += `INSERT INTO matches (
    home_team_id, 
    away_team_id, 
    match_type_id, 
    match_date,
    match_time,
    source_system_id,
    external_id
) 
SELECT 
    (SELECT id FROM teams WHERE name = '${match.home.replace(/'/g, "''")}' AND source_system_id = 2),
    (SELECT id FROM teams WHERE name = '${match.away.replace(/'/g, "''")}' AND source_system_id = 2),
    ${getMatchTypeId(match.status)},
    '${dateTime.date}'::date,
    '${dateTime.time}'::time,
    2, -- CASA source_system_id
    'casa-${division.external_id}-${matchCount}'
WHERE EXISTS (SELECT 1 FROM teams WHERE name = '${match.home.replace(/'/g, "''")}' AND source_system_id = 2)
  AND EXISTS (SELECT 1 FROM teams WHERE name = '${match.away.replace(/'/g, "''")}' AND source_system_id = 2);\n\n`;
      
      // Add match score if available
      if (score && match.status === 'Final') {
        sql += `-- Update score for completed match\n`;
        sql += `UPDATE matches 
SET home_score = ${score.home}, 
    away_score = ${score.away},
    match_status_id = 3 -- Completed
WHERE external_id = 'casa-${division.external_id}-${matchCount}';\n\n`;
      }
      
      matchCount++;
    }
    
    sql += '\n';
  }
  
  sql += `-- ============================================================================
-- Summary
-- ============================================================================
-- Total matches inserted: ${matchCount}
-- Note: Matches with missing teams (not in database) will be skipped
-- Missing teams detected: Philadelphia Sierra Stars, Phoenix Reserves, Philly BlackStars
-- These teams need to be added or mapped to existing teams
`;
  
  fs.writeFileSync(OUTPUT_SQL, sql);
  console.log(`✓ Generated ${OUTPUT_SQL}`);
  console.log(`  Total matches: ${matchCount}`);
  console.log(`  Note: Some matches reference teams not in database (will be skipped)`);
}

// Run
try {
  generateMatchSQL();
} catch (error) {
  console.error('Error generating matches SQL:', error);
  process.exit(1);
}
