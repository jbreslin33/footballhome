#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// scripts/gcal-rsvp-apply-standing.js — Slice 6a §6.5.3 applier
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// For every fh_events row whose RSVP window has opened but the
// standing-applier has not yet processed, insert `fh_event_rsvps`
// rows for every roster-eligible user with an active
// `fh_recurring_rsvps` pref matching the event's kind+category,
// then stamp `fh_events.standing_applied_at = now()`.
//
// Runs on its own systemd timer (5 min cadence) independent of
// gcal-sync — they touch different tables and different locks so
// they can run in parallel without issue.
//
// Contract:
//
//   * Idempotent.  standing_applied_at gates each event to exactly
//     one applier run for its lifetime.  Re-running the worker is a
//     no-op for events already stamped.
//
//   * Manual RSVPs always win.  The INSERT uses ON CONFLICT
//     (fh_event_id, person_id) DO NOTHING — an existing manual (or
//     admin) row silently blocks the auto-standing insert.  Users
//     who click YES/NO before the applier fires keep their manual
//     answer; those who don't click get their standing default.
//
//   * Category NULL on the standing pref matches ANY event
//     category, including events with NULL category.  Category NULL
//     on the event only matches standing prefs with NULL category
//     (strict — no "mens" pref auto-registers on a joint
//     multi-category practice).
//
//   * Roster eligibility flows: fh_event_teams → teams →
//     player_rsvp_eligibility.team_id → LA user ID →
//     external_person_aliases → persons.  Same chain the write
//     endpoint (POST /api/calendar/rsvp) uses, so anything the
//     applier auto-registers is also something the user could have
//     manually RSVP'd for.
//
//   * Skips events whose starts_at is > 1 day in the past — no
//     point creating auto-RSVPs for historical events.  If an event
//     with a still-open window sits unapplied because it was
//     freshly inserted, that gap closes on the next timer tick.
//
// Run: node scripts/gcal-rsvp-apply-standing.js
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require('dotenv').config({ path: __dirname + '/../env' });
const { Pool } = require('pg');

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
  let totalEvents      = 0;
  let totalInserted    = 0;
  let totalSkipped     = 0;   // event with no matching standing prefs OR no eligible users
  let totalStamped     = 0;
  const perEventStats  = [];

  try {
    // Pull the batch of candidate events.  The applier scan index
    // (fh_events_applier_scan_idx from migration 119) makes this
    // point-in-time cheap even with 1000+ fh_events rows.
    //
    // starts_at > now() - 1 day filters out events already in the
    // past — no point creating standing RSVPs for events already
    // occurred.  Widening this window (say to '7 days') would
    // populate historical stats but distort attendance/audit data.
    const eventsRes = await client.query(`
      SELECT fe.id, fe.kind, fe.category, ge.summary,
             to_char(ge.starts_at AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS starts_at
        FROM fh_events   fe
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
       WHERE fe.rsvps_open_at IS NOT NULL
         AND fe.rsvps_open_at   <= now()
         AND fe.standing_applied_at IS NULL
         AND ge.deleted_at IS NULL
         AND ge.status <> 'cancelled'
         AND ge.starts_at > now() - INTERVAL '1 day'
       ORDER BY ge.starts_at ASC
    `);

    totalEvents = eventsRes.rows.length;
    if (totalEvents === 0) {
      console.log('[apply-standing] no candidate events — nothing to do.');
      return;
    }
    console.log(`[apply-standing] processing ${totalEvents} events…`);

    // Iterate per-event with a transaction: insert rows + stamp
    // standing_applied_at atomically.  A crashed worker mid-loop
    // leaves earlier events fully applied and later ones untouched
    // (safe — the next tick picks them up).
    for (const ev of eventsRes.rows) {
      await client.query('BEGIN');
      try {
        // The nested SELECT computes the set of persons who:
        //   1. are on at least one team attached to the event
        //      (fh_event_teams → player_rsvp_eligibility)
        //   2. have an active standing pref whose kind matches
        //      AND whose category matches the event's category
        //      OR is NULL (see contract).
        // The outer INSERT deduplicates via DISTINCT (a person on
        // multiple attached teams should still get one RSVP row)
        // and ON CONFLICT DO NOTHING (manual RSVPs win).
        const insertRes = await client.query(`
          INSERT INTO fh_event_rsvps
              (fh_event_id, person_id, response, responded_at, created_via)
          SELECT DISTINCT $1::bigint, epa.person_id, frr.response,
                          now(), 'standing'
            FROM fh_event_teams fet
            JOIN player_rsvp_eligibility ple
              ON ple.team_id = fet.team_id
            JOIN external_person_aliases epa
              ON epa.provider = 'leagueapps'
             AND epa.external_user_id = ple.leagueapps_user_id::text
            JOIN fh_recurring_rsvps frr
              ON frr.person_id = epa.person_id
             AND frr.active    = true
             AND frr.kind      = $2::text
             AND ( ($3::text IS NULL AND frr.category IS NULL)
                OR ($3::text IS NOT NULL AND frr.category = $3::text)
                OR frr.category IS NULL )
           WHERE fet.fh_event_id = $1::bigint
          ON CONFLICT (fh_event_id, person_id) DO NOTHING
        `, [ev.id, ev.kind, ev.category]);

        // Stamp regardless of whether any rows inserted — the
        // stamp represents "applier considered this event", not
        // "applier inserted rows for this event".  Absent this,
        // an event with no matching standing prefs would be
        // reconsidered on every tick forever.
        await client.query(
          'UPDATE fh_events SET standing_applied_at = now() WHERE id = $1::bigint',
          [ev.id]
        );

        await client.query('COMMIT');

        totalInserted += insertRes.rowCount;
        totalStamped  += 1;
        if (insertRes.rowCount === 0) totalSkipped += 1;

        perEventStats.push({
          fh_event_id: ev.id,
          summary:     ev.summary,
          starts_at:   ev.starts_at,
          kind:        ev.kind,
          category:    ev.category,
          inserted:    insertRes.rowCount,
        });
      } catch (e) {
        await client.query('ROLLBACK');
        console.error(`[apply-standing] event ${ev.id} rolled back:`, e.message);
      }
    }
  } finally {
    client.release();
    await pool.end();
  }

  // Summary — one line per event so systemd journal has enough
  // context to diagnose "why didn't Bob get auto-RSVP'd?" without
  // needing to re-run against the DB.
  console.log('[apply-standing] per-event:');
  for (const s of perEventStats) {
    console.log(
      `  fh_event_id=${s.fh_event_id} kind=${s.kind} ` +
      `category=${s.category ?? 'null'} starts=${s.starts_at} ` +
      `inserted=${s.inserted}  "${(s.summary || '').slice(0, 60)}"`
    );
  }
  console.log(
    `[apply-standing] done. events=${totalEvents} stamped=${totalStamped} ` +
    `inserted=${totalInserted} zero-insert-events=${totalSkipped}`
  );
}

main().catch((err) => {
  console.error('[apply-standing] fatal:', err);
  process.exit(1);
});
