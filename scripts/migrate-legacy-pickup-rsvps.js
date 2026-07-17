#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// scripts/migrate-legacy-pickup-rsvps.js — Slice 7 one-shot
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Copy per-event pickup RSVPs from the legacy `player_rsvp_history`
// log (indexed on `matches` rows with `match_type_id = 7`) into
// `fh_event_rsvps`, keyed on the same-date `fh_events` row that
// Slice 6b's classifier already emitted (kind='pickup',
// category='mens').
//
// Semantics
// ─────────
//
//   * "Latest wins": for each (event_id, player_id) pair in
//     `player_rsvp_history`, take the row with the largest
//     `changed_at`.  The history is an immutable append log so
//     older rows are audit trail, not current state.
//
//   * Only match_type_id = 7 matches are eligible.  Every other
//     match_type stays on the legacy path.
//
//   * `matches.match_date` is joined against
//     `(gcal_events.starts_at AT TIME ZONE 'America/New_York')::date`.
//     Both are calendar dates in the club's local timezone.  A
//     legacy pickup that falls on a day with no fh_events row (e.g.
//     ad-hoc Tuesday pickups the gcal classifier never saw) is
//     REPORTED and SKIPPED — never invented.
//
//   * Category is hard-coded to `mens`.  All 7 legacy pickup rows
//     in prod as of 2026-07-17 are Mens Saturday/Tuesday/Thursday.
//     Non-mens categories will surface as unmatched (skipped, then
//     manually revisited) rather than silently misfiled.
//
//   * `player_id → person_id` via `players.person_id`.  Players
//     without a linked person row are reported and skipped.
//
//   * `created_via = 'manual'` on the inserted row.  These WERE
//     manual clicks in the legacy app; the migration just relocates
//     the record.  `responded_at = changed_at` from the source row
//     preserves the audit timeline.
//
//   * ON CONFLICT (fh_event_id, person_id) DO NOTHING.  If the
//     standing-applier already inserted a `created_via='standing'`
//     row before this migration runs, we leave it alone.  In
//     practice this only matters for future-dated events (past
//     events aren't touched by the applier — see the `starts_at >
//     now() - 1 day` gate in gcal-rsvp-apply-standing.js).
//
// Idempotency
// ───────────
//
// This script is safe to re-run.  The ON CONFLICT clause plus the
// "latest wins" MAX-per-pair aggregation means running it N times
// produces the same final state as running it once.  There is no
// "already migrated" flag on matches or fh_events — we rely on the
// unique constraint alone.
//
// Modes
// ─────
//
//   node scripts/migrate-legacy-pickup-rsvps.js            # DRY-RUN
//   node scripts/migrate-legacy-pickup-rsvps.js --apply    # LIVE
//
// The default is dry-run: it prints what WOULD be inserted plus
// per-event / global stats, without mutating a single row.  Pass
// --apply after reviewing the report.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require('dotenv').config({ path: __dirname + '/../env' });
const { Pool } = require('pg');

const APPLY = process.argv.includes('--apply');

const DB = {
  host:     process.env.PGHOST     || 'localhost',
  port:     parseInt(process.env.PGPORT || '5432', 10),
  database: process.env.PGDATABASE || 'footballhome',
  user:     process.env.PGUSER     || 'footballhome_user',
  password: process.env.PGPASSWORD || 'footballhome_pass',
};

async function main() {
  const pool = new Pool(DB);
  const client = await pool.connect();

  const mode = APPLY ? 'APPLY' : 'DRY-RUN';
  console.log(`[migrate-legacy-pickup] mode=${mode}`);

  try {
    // Step 1: enumerate legacy pickup matches for FUTURE dates only.
    // Past events are not migrated — nobody's going to click RSVP
    // for a game that already happened, and the legacy screen can
    // still surface historical attendance if needed.
    const matchesRes = await client.query(`
      SELECT m.id AS match_id, m.match_date, m.title
        FROM matches m
       WHERE m.match_type_id = 7
         AND m.match_date >= CURRENT_DATE
       ORDER BY m.match_date ASC, m.id ASC
    `);
    console.log(`[migrate-legacy-pickup] found ${matchesRes.rows.length} future legacy pickup matches (match_type_id=7, match_date >= today).`);

    let totalMatchedFhEvents = 0;
    let totalUnmatched       = 0;
    let totalPlayersConsidered = 0;
    let totalPlayersLinked   = 0;
    let totalPlayersUnlinked = 0;
    let totalWouldInsert     = 0;
    let totalWouldConflict   = 0;

    // Step 2: per-match, find the fh_events row on the same date.
    for (const m of matchesRes.rows) {
      const fhRes = await client.query(`
        SELECT fe.id, fe.kind, fe.category,
               to_char(ge.starts_at AT TIME ZONE 'America/New_York', 'YYYY-MM-DD HH24:MI') AS local_ts
          FROM fh_events   fe
          JOIN gcal_events ge ON ge.id = fe.gcal_event_id
         WHERE fe.kind = 'pickup'
           AND fe.category = 'mens'
           AND (ge.starts_at AT TIME ZONE 'America/New_York')::date = $1::date
           AND ge.deleted_at IS NULL
           AND ge.status <> 'cancelled'
         ORDER BY ge.starts_at ASC
         LIMIT 1
      `, [m.match_date]);

      if (fhRes.rows.length === 0) {
        totalUnmatched += 1;
        console.log(
          `  match_id=${m.match_id} date=${m.match_date.toISOString().slice(0,10)} ` +
          `title="${m.title || ''}"  →  NO fh_events row on this date, skipping.`
        );
        continue;
      }
      totalMatchedFhEvents += 1;
      const fh = fhRes.rows[0];

      // Step 3: latest-per-player from player_rsvp_history for this
      // legacy match.  DISTINCT ON (player_id) ORDER BY player_id,
      // changed_at DESC gives us the most recent status only.
      const rsvpRes = await client.query(`
        SELECT DISTINCT ON (prh.player_id)
               prh.player_id,
               p.person_id,
               prh.rsvp_status_id,
               rs.name AS status_name,
               prh.changed_at
          FROM player_rsvp_history prh
          JOIN players p        ON p.id = prh.player_id
          JOIN rsvp_statuses rs ON rs.id = prh.rsvp_status_id
         WHERE prh.event_id = $1
         ORDER BY prh.player_id, prh.changed_at DESC
      `, [m.match_id]);

      let localWouldInsert   = 0;
      let localWouldConflict = 0;
      let localUnlinked      = 0;

      for (const r of rsvpRes.rows) {
        totalPlayersConsidered += 1;

        if (r.person_id == null) {
          totalPlayersUnlinked += 1;
          localUnlinked += 1;
          continue;
        }
        totalPlayersLinked += 1;

        // Check if a row already exists in fh_event_rsvps.
        const conflictRes = await client.query(`
          SELECT 1 FROM fh_event_rsvps
           WHERE fh_event_id = $1::bigint AND person_id = $2::int
           LIMIT 1
        `, [fh.id, r.person_id]);

        if (conflictRes.rows.length > 0) {
          localWouldConflict += 1;
          totalWouldConflict += 1;
          continue;
        }

        localWouldInsert += 1;
        totalWouldInsert += 1;

        if (APPLY) {
          await client.query(`
            INSERT INTO fh_event_rsvps
                (fh_event_id, person_id, response, responded_at, created_via)
            VALUES
                ($1::bigint, $2::int, $3::text, $4::timestamptz, 'manual')
            ON CONFLICT (fh_event_id, person_id) DO NOTHING
          `, [fh.id, r.person_id, r.status_name, r.changed_at]);
        }
      }

      console.log(
        `  match_id=${m.match_id} date=${m.match_date.toISOString().slice(0,10)} ` +
        `title="${m.title || ''}"  →  fh_event_id=${fh.id} local=${fh.local_ts}  ` +
        `players_seen=${rsvpRes.rows.length} would_insert=${localWouldInsert} ` +
        `already_present=${localWouldConflict} unlinked=${localUnlinked}`
      );
    }

    console.log('');
    console.log('[migrate-legacy-pickup] summary:');
    console.log(`  legacy matches total .............. ${matchesRes.rows.length}`);
    console.log(`  matched to fh_events row .......... ${totalMatchedFhEvents}`);
    console.log(`  unmatched (no same-date fh row) ... ${totalUnmatched}`);
    console.log(`  distinct-player RSVPs considered .. ${totalPlayersConsidered}`);
    console.log(`    linked to a person ............. ${totalPlayersLinked}`);
    console.log(`    unlinked (players.person_id NULL) ${totalPlayersUnlinked}`);
    console.log(`  would insert ...................... ${totalWouldInsert}`);
    console.log(`  would skip (already present) ...... ${totalWouldConflict}`);

    if (!APPLY) {
      console.log('');
      console.log('[migrate-legacy-pickup] DRY-RUN — no rows written.  Re-run with --apply to commit.');
    } else {
      console.log('');
      console.log(`[migrate-legacy-pickup] APPLIED — ${totalWouldInsert} rows inserted.`);
    }
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(err => {
  console.error('[migrate-legacy-pickup] FATAL:', err);
  process.exit(1);
});
