#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// scripts/migrate-legacy-pickup-standing.js — Slice 7 one-shot
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Copy legacy Saturday Mens Pickup standing prefs from
// `player_recurring_rsvps` (keyed on person_id + day_of_week +
// match_type_id) into the new `fh_recurring_rsvps` shape (keyed on
// person_id + kind + category).
//
// Scope
// ─────
//
//   SELECT * FROM player_recurring_rsvps
//     WHERE day_of_week   = 6   -- Saturday
//       AND match_type_id = 7   -- Pickup
//       AND rsvp_status_id = 1  -- yes
//
//   → INSERT INTO fh_recurring_rsvps
//         (person_id, kind='pickup', category='mens',
//          response='yes', active=true)
//
// NO / MAYBE prefs are intentionally NOT migrated.  The new UI's
// default state IS "no auto-RSVP", so a legacy `no` pref is
// already the default and doesn't need a persisted row.  A legacy
// `maybe` pref is meaningless in a system whose applier can only
// choose YES (see gcal-rsvp-apply-standing.js — it takes
// frr.response directly, and a maybe response wouldn't fire a
// notification anyone would act on).
//
// Wed/Fri practice standing prefs (match_type_id=3) are also NOT
// migrated — this slice's scope is pickup only.  When the practice
// side of the new events model comes online, a sibling script can
// handle those.
//
// Idempotency
// ───────────
//
// ON CONFLICT (person_id, kind, COALESCE(category, '')) DO NOTHING
// against the functional unique index from migration 119.  Re-running
// is a no-op — existing rows (whether from a prior run of this
// migration OR from the user having toggled the profile switch
// themselves) are preserved as-is.  This script never overrides
// a user's own action.
//
// Modes
// ─────
//
//   node scripts/migrate-legacy-pickup-standing.js            # DRY-RUN
//   node scripts/migrate-legacy-pickup-standing.js --apply    # LIVE
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
  console.log(`[migrate-pickup-standing] mode=${mode}`);

  try {
    // Enumerate legacy YES prefs for Saturday Pickup.  Left-join
    // the new table to compute would-conflict vs would-insert
    // per-person in one round trip.
    const rows = await client.query(`
      SELECT prr.person_id,
             p.first_name, p.last_name,
             prr.created_at AS legacy_created_at,
             EXISTS (
               SELECT 1 FROM fh_recurring_rsvps frr
                WHERE frr.person_id = prr.person_id
                  AND frr.kind      = 'pickup'
                  AND frr.category  = 'mens'
             ) AS already_present
        FROM player_recurring_rsvps prr
        JOIN persons p ON p.id = prr.person_id
       WHERE prr.day_of_week   = 6
         AND prr.match_type_id = 7
         AND prr.rsvp_status_id = 1
       ORDER BY p.last_name, p.first_name
    `);

    let wouldInsert   = 0;
    let wouldConflict = 0;

    console.log(`[migrate-pickup-standing] legacy YES prefs for Sat pickup: ${rows.rows.length}`);
    console.log('');
    console.log('  person_id  status              name');
    console.log('  ─────────  ──────────────────  ──────────────────────────────');
    for (const r of rows.rows) {
      const status = r.already_present ? 'SKIP (fh row exists)' : 'INSERT';
      if (r.already_present) wouldConflict += 1; else wouldInsert += 1;
      console.log(
        `  ${String(r.person_id).padEnd(9)}  ${status.padEnd(18)}  ${r.first_name || ''} ${r.last_name || ''}`
      );
    }

    console.log('');
    console.log('[migrate-pickup-standing] summary:');
    console.log(`  legacy YES prefs .................. ${rows.rows.length}`);
    console.log(`  would insert ...................... ${wouldInsert}`);
    console.log(`  would skip (fh row already there) . ${wouldConflict}`);

    if (APPLY && wouldInsert > 0) {
      await client.query('BEGIN');
      try {
        const insertRes = await client.query(`
          INSERT INTO fh_recurring_rsvps
              (person_id, kind, category, response, active, created_at, updated_at)
          SELECT prr.person_id, 'pickup'::text, 'mens'::text, 'yes'::text,
                 true, now(), now()
            FROM player_recurring_rsvps prr
           WHERE prr.day_of_week    = 6
             AND prr.match_type_id  = 7
             AND prr.rsvp_status_id = 1
          ON CONFLICT (person_id, kind, COALESCE(category, '')) DO NOTHING
        `);
        await client.query('COMMIT');
        console.log('');
        console.log(`[migrate-pickup-standing] APPLIED — ${insertRes.rowCount} rows inserted.`);
      } catch (e) {
        await client.query('ROLLBACK');
        throw e;
      }
    } else if (!APPLY) {
      console.log('');
      console.log('[migrate-pickup-standing] DRY-RUN — no rows written.  Re-run with --apply to commit.');
    } else {
      console.log('');
      console.log('[migrate-pickup-standing] APPLIED — nothing to insert (all prefs already present).');
    }
  } finally {
    client.release();
    await pool.end();
  }
}

main().catch(err => {
  console.error('[migrate-pickup-standing] FATAL:', err);
  process.exit(1);
});
