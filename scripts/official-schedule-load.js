#!/usr/bin/env node
// Load one official league schedule read in Chrome into league_fixtures (mig 758).
//
// GotSport (PPR youth) and TeamSnap (Tri County women) turn the server away,
// so Claude in Chrome reads the team's schedule page and writes a JSON file:
//
//   { "program_id": "57473/4408462",            // league_fixture_sources.program_id
//     "read_at":    "2026-10-27T11:57:00-04:00", // when the page was read
//     "fixtures": [ { "external_id": "67",
//                     "starts_at":   "2026-10-31 08:00",   // America/New_York
//                     "status":      "scheduled",          // or cancelled / completed
//                     "home_name": "...", "away_name": "...",
//                     "venue_name": "...", "venue_detail": "...",
//                     "home_score": null, "away_score": null } ] }
//
// Every fixture in the file is upserted with last_seen_at = read_at; a game
// of that source missing from the file gets removed_at (the league dropped
// it); the source's last_fetched_at becomes read_at.  The file must be the
// team's WHOLE schedule — a partial read would retire the games it left out.
//
//   node scripts/official-schedule-load.js <file.json> [<file.json> …]

require('dotenv').config({ path: __dirname + '/../env' });
const fs = require('fs');
const { Pool } = require('pg');

const pool = new Pool({
  host:     process.env.PGHOST     || 'localhost',
  port:     parseInt(process.env.PGPORT || '5432', 10),
  database: process.env.PGDATABASE || 'footballhome',
  user:     process.env.PGUSER     || 'footballhome_user',
  password: process.env.PGPASSWORD || process.env.POSTGRES_PASSWORD || 'footballhome_pass',
});

async function load(file) {
  const doc = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (!doc.program_id || !doc.read_at || !Array.isArray(doc.fixtures) || !doc.fixtures.length)
    throw new Error(`${file}: needs program_id, read_at and a non-empty fixtures list`);
  const c = await pool.connect();
  try {
    await c.query('BEGIN');
    const { rows: [src] } = await c.query(
      `SELECT id, label FROM league_fixture_sources WHERE program_id = $1 AND system IN ('gotsport','teamsnap')`, [doc.program_id]);
    if (!src) throw new Error(`${file}: no gotsport/teamsnap source with program_id ${doc.program_id}`);
    for (const f of doc.fixtures) {
      // A zone-less time is the league's local time.
      const startsSql = /[zZ]|[+-]\d\d:?\d\d$/.test(f.starts_at) ? '$3::timestamptz' : `($3::timestamp AT TIME ZONE 'America/New_York')`;
      await c.query(
        `INSERT INTO league_fixtures (source_id, external_id, starts_at, status, home_name, away_name,
                                      venue_name, venue_detail, home_score, away_score, last_seen_at, removed_at)
         VALUES ($1, $2, ${startsSql}, $4, $5, $6, $7, $8, $9, $10, $11::timestamptz, NULL)
         ON CONFLICT (source_id, external_id) DO UPDATE SET
           starts_at = EXCLUDED.starts_at, status = EXCLUDED.status,
           home_name = EXCLUDED.home_name, away_name = EXCLUDED.away_name,
           venue_name = EXCLUDED.venue_name, venue_detail = EXCLUDED.venue_detail,
           home_score = EXCLUDED.home_score, away_score = EXCLUDED.away_score,
           last_seen_at = EXCLUDED.last_seen_at, removed_at = NULL`,
        [src.id, String(f.external_id), f.starts_at, f.status || 'scheduled', f.home_name, f.away_name,
         f.venue_name || null, f.venue_detail || null, f.home_score ?? null, f.away_score ?? null, doc.read_at]);
    }
    const { rowCount: gone } = await c.query(
      `UPDATE league_fixtures SET removed_at = $2::timestamptz
        WHERE source_id = $1 AND removed_at IS NULL AND last_seen_at < $2::timestamptz`, [src.id, doc.read_at]);
    await c.query(
      `UPDATE league_fixture_sources SET last_fetched_at = $2::timestamptz, last_fetch_ok = true, last_fetch_note = $3 WHERE id = $1`,
      [src.id, doc.read_at, `${doc.fixtures.length} games (read in Chrome)`]);
    await c.query('COMMIT');
    console.log(`${src.label}: ${doc.fixtures.length} games, ${gone} removed, read ${doc.read_at}`);
  } catch (e) { await c.query('ROLLBACK'); throw e; }
  finally { c.release(); }
}

(async () => {
  const files = process.argv.slice(2);
  if (!files.length) { console.error('usage: official-schedule-load.js <file.json> …'); process.exit(2); }
  for (const f of files) await load(f);
  await pool.end();
})().catch(e => { console.error(e.message); process.exit(1); });
