// standings-scraper.js
// Minimal scraper stub: parse an HTML standings page (local file or fetched URL)
// and write an idempotent SQL file under database/data/

const fs = require('fs');
const path = require('path');
const jsdom = require('jsdom');
const { JSDOM } = jsdom;

async function loadHtml(source) {
  if (/^https?:\/\//.test(source)) {
    const fetch = require('node-fetch');
    const res = await fetch(source);
    return await res.text();
  }
  return fs.readFileSync(source, 'utf8');
}

function normalizeTeamName(name) {
  return name.trim();
}

async function scrapeToSql(source, outFile, opts = {}) {
  const html = await loadHtml(source);
  const dom = new JSDOM(html);
  const doc = dom.window.document;

  // This stub assumes standings are in a table with rows containing team and stats
  const rows = Array.from(doc.querySelectorAll('table tr'));
  const entries = [];
  rows.forEach(tr => {
    const cols = Array.from(tr.querySelectorAll('td')).map(td => td.textContent.trim());
    if (cols.length >= 10) {
      // example mapping - adapt to actual provider
      const [position, team, played, wins, draws, losses, gf, ga, gd, points] = cols;
      entries.push({ position, team: normalizeTeamName(team), played, wins, draws, losses, gf, ga, gd, points });
    }
  });

  if (entries.length === 0) {
    console.warn('No standings rows detected - adjust selector in scraper stub');
  }

  // Compose SQL with ON CONFLICT upsert by competition_id/season_id/team_id.
  // NOTE: team resolution to `teams.id` must be handled elsewhere.
  const competitionId = opts.competitionId || 'NULL';
  const seasonId = opts.seasonId || 'NULL';
  const fetchedAt = new Date().toISOString();
  const sourceUrl = opts.source || source;

  let sql = `-- Generated standings SQL for ${sourceUrl}\n`;
  sql += `-- fetched_at: ${fetchedAt}\n`;

  entries.forEach(e => {
    // Placeholder: the scraper should resolve `team_id` by looking up or creating team.
    // Here we emit a comment and an insert using a lookup by canonical team name.
    const escapedTeam = e.team.replace(/'/g, "''");
    sql += `-- Team: ${escapedTeam}\n`;
    sql += `WITH t AS (SELECT id FROM teams WHERE lower(display_name)=lower('${escapedTeam}') LIMIT 1)
INSERT INTO standings (competition_id, season_id, team_id, position, played, wins, draws, losses, goals_for, goals_against, goal_diff, points, fetched_at, source)
SELECT ${competitionId}, ${seasonId}, t.id, ${parseInt(e.position)||'NULL'}, ${parseInt(e.played)||'NULL'}, ${parseInt(e.wins)||'NULL'}, ${parseInt(e.draws)||'NULL'}, ${parseInt(e.losses)||'NULL'}, ${parseInt(e.gf)||'NULL'}, ${parseInt(e.ga)||'NULL'}, ${parseInt(e.gd)||'NULL'}, ${parseInt(e.points)||'NULL'}, '${fetchedAt}', '${sourceUrl}'
FROM t
ON CONFLICT (competition_id, season_id, team_id) DO UPDATE SET position=EXCLUDED.position, played=EXCLUDED.played, wins=EXCLUDED.wins, draws=EXCLUDED.draws, losses=EXCLUDED.losses, goals_for=EXCLUDED.goals_for, goals_against=EXCLUDED.goals_against, goal_diff=EXCLUDED.goal_diff, points=EXCLUDED.points, fetched_at=EXCLUDED.fetched_at, source=EXCLUDED.source;
\n`;
  });

  fs.writeFileSync(outFile, sql, 'utf8');
  console.log('Wrote', outFile);
}

if (require.main === module) {
  const argv = process.argv.slice(2);
  const source = argv[0] || 'path/to/standings.html';
  const out = argv[1] || path.join(__dirname, '../../data/028-standings.sql');
  scrapeToSql(source, out).catch(err => { console.error(err); process.exit(1); });
}

module.exports = { scrapeToSql };
