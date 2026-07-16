#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// scripts/gcal-sync.js — Google Calendar → Postgres mirror (Slice 2)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// Reads gcal_calendars (seeded by migration 119), fetches events from
// each Google Calendar it lists, and UPSERTs them into gcal_events.
// One-shot script — run by the systemd timer `systemd/gcal-sync.timer`
// every 5 minutes. Also safe to run by hand from the CLI:
//
//   node scripts/gcal-sync.js
//
// Behavior (see docs/calendar-design.md §7 for the design):
//
//   * First run on a calendar (sync_token IS NULL) does a FULL sync
//     over a rolling window (30 days back, 365 days forward).
//   * Every run after that does an INCREMENTAL sync using Google's
//     opaque `syncToken` cursor — returns only what changed.
//   * On 410 GONE (token expired) we transparently fall back to a
//     full re-sync.
//   * `singleEvents: true` — recurring events are expanded so each
//     Sat pickup instance becomes its own row (matches what the §6.1
//     classifier expects to see).
//   * Cancelled events → tombstoned (deleted_at = now()). We NEVER
//     physical-DELETE a gcal_events row. This is §1.1 in the schema:
//     fh_events FK is ON DELETE RESTRICT.
//   * Content-hash change detection: if the meaningful fields
//     (summary, description, location, start, end, status,
//     recurringEventId) haven't changed, we only bump `last_seen_at`
//     and skip the UPDATE. Cheap when nothing's changed, and gives
//     us "when did we last confirm this event still exists".
//
// DB connection: standard PG* env vars fall back to the defaults from
// docker-compose.yml (footballhome_user / footballhome_pass on
// localhost:5432). Override in env when needed.
//
// Auth: service account JSON in GCAL_SA_JSON (see scripts/gcal-test.js
// header for the setup path). Read-only scope — this script cannot
// mutate the calendar even by accident.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require('dotenv').config({ path: __dirname + '/../env' });
const { google } = require('googleapis');
const { Pool }   = require('pg');
const crypto     = require('crypto');

// ─── DB ───────────────────────────────────────────────────────────────
const DB = {
  host:     process.env.PGHOST     || 'localhost',
  port:     parseInt(process.env.PGPORT || '5432', 10),
  database: process.env.PGDATABASE || 'footballhome',
  user:     process.env.PGUSER     || 'footballhome_user',
  password: process.env.PGPASSWORD || 'footballhome_pass',
};

// ─── Google auth ──────────────────────────────────────────────────────
if (!process.env.GCAL_SA_JSON) {
  console.error('gcal-sync: GCAL_SA_JSON not set (see scripts/gcal-test.js header)');
  process.exit(2);
}
const creds = JSON.parse(process.env.GCAL_SA_JSON);
const auth  = new google.auth.GoogleAuth({
  credentials: creds,
  scopes: ['https://www.googleapis.com/auth/calendar.readonly'],
});
const gcal = google.calendar({ version: 'v3', auth });

// ─── Full-sync window ─────────────────────────────────────────────────
// 30 days back gives us recent past events (useful for attendance
// backfill later); 365 days forward covers a full season of recurring
// pickup / practice instances.
const DAY = 86400 * 1000;
const timeMin = () => new Date(Date.now() -  30 * DAY).toISOString();
const timeMax = () => new Date(Date.now() + 365 * DAY).toISOString();

// ─── Content hash ─────────────────────────────────────────────────────
// SHA256 over the fields we actually care about. Google bumps
// updated/etag on trivial changes (like colorId) which we don't want
// to trigger an UPDATE for.
function eventHash(e) {
  const canonical = JSON.stringify({
    summary:            e.summary            || '',
    description:        e.description        || '',
    location:           e.location           || '',
    start:              e.start?.dateTime    || e.start?.date || '',
    end:                e.end?.dateTime      || e.end?.date   || '',
    status:             e.status             || '',
    recurringEventId:   e.recurringEventId   || '',
    htmlLink:           e.htmlLink           || '',
  });
  return crypto.createHash('sha256').update(canonical).digest('hex');
}

// ─── Upsert one event ─────────────────────────────────────────────────
// Returns { action } for stats.
async function upsertEvent(pg, calendarId, e) {
  // Cancelled events: tombstone. Google sends these for both:
  //   (a) an entire event being cancelled by the organizer, and
  //   (b) a single instance of a recurring event being deleted,
  //       which arrives with just { id, status: 'cancelled' } and
  //       (usually) no start/end.
  // Either way, we tombstone the row if we know it, insert a
  // minimal tombstoned row if we don't.
  if (e.status === 'cancelled') {
    const r = await pg.query(`
      UPDATE gcal_events
      SET deleted_at   = COALESCE(deleted_at, now()),
          last_seen_at = now(),
          status       = 'cancelled'
      WHERE calendar_id = $1 AND google_event_id = $2
    `, [calendarId, e.id]);
    return { action: r.rowCount ? 'tombstone' : 'skip' };
  }

  const startISO = e.start?.dateTime || e.start?.date;
  const endISO   = e.end?.dateTime   || e.end?.date;
  if (!startISO || !endISO) return { action: 'skip' };

  const allDay = !e.start?.dateTime;
  const hash   = eventHash(e);

  // Fast path: if content hash unchanged, only bump last_seen_at.
  // Also clears deleted_at in case a previously-tombstoned event
  // came back (Google occasionally does this — see §1.1).
  const cur = await pg.query(`
    SELECT hash, deleted_at FROM gcal_events
    WHERE calendar_id = $1 AND google_event_id = $2
  `, [calendarId, e.id]);

  if (cur.rows.length && cur.rows[0].hash === hash && cur.rows[0].deleted_at === null) {
    await pg.query(`
      UPDATE gcal_events SET last_seen_at = now()
      WHERE calendar_id = $1 AND google_event_id = $2
    `, [calendarId, e.id]);
    return { action: 'unchanged' };
  }

  const r = await pg.query(`
    INSERT INTO gcal_events (
      calendar_id, google_event_id, recurring_event_id,
      summary, description, location, starts_at, ends_at,
      all_day, status, html_link, hash, raw
    ) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
    ON CONFLICT (calendar_id, google_event_id) DO UPDATE SET
      recurring_event_id = EXCLUDED.recurring_event_id,
      summary            = EXCLUDED.summary,
      description        = EXCLUDED.description,
      location           = EXCLUDED.location,
      starts_at          = EXCLUDED.starts_at,
      ends_at            = EXCLUDED.ends_at,
      all_day            = EXCLUDED.all_day,
      status             = EXCLUDED.status,
      html_link          = EXCLUDED.html_link,
      hash               = EXCLUDED.hash,
      raw                = EXCLUDED.raw,
      last_seen_at       = now(),
      deleted_at         = NULL
    RETURNING (xmax = 0) AS inserted
  `, [
    calendarId, e.id, e.recurringEventId || null,
    e.summary || null, e.description || null, e.location || null,
    startISO, endISO,
    allDay, e.status, e.htmlLink || null, hash, JSON.stringify(e),
  ]);
  return { action: r.rows[0]?.inserted ? 'insert' : 'update' };
}

// ─── Sync one calendar ────────────────────────────────────────────────
async function syncCalendar(pg, cal) {
  console.log(`\n[${cal.role}] ${cal.google_id}`);
  let syncToken     = cal.sync_token || null;
  let pageToken     = undefined;
  let nextSyncToken = null;
  let mode          = syncToken ? 'incremental' : 'full';
  const stats       = { insert: 0, update: 0, unchanged: 0, tombstone: 0, skip: 0 };

  // Retry loop for the 410-GONE fallback.
  let attemptsLeft = 2;
  while (attemptsLeft-- > 0) {
    try {
      do {
        const params = {
          calendarId:   cal.google_id,
          singleEvents: true,      // expand recurring
          maxResults:   250,
          pageToken,
        };
        if (syncToken) {
          params.syncToken = syncToken;
        } else {
          params.timeMin = timeMin();
          params.timeMax = timeMax();
        }

        const res = await gcal.events.list(params);
        for (const e of res.data.items || []) {
          const r = await upsertEvent(pg, cal.id, e);
          stats[r.action] = (stats[r.action] || 0) + 1;
        }
        pageToken = res.data.nextPageToken || undefined;
        if (!pageToken && res.data.nextSyncToken) {
          nextSyncToken = res.data.nextSyncToken;
        }
      } while (pageToken);
      break;  // done — exit retry loop
    } catch (err) {
      if (err.code === 410 && syncToken) {
        console.log('  syncToken expired (410) — falling back to full sync');
        syncToken = null;
        pageToken = undefined;
        mode      = 'full';
        continue;
      }
      throw err;
    }
  }

  await pg.query(`
    UPDATE gcal_calendars
    SET sync_token     = COALESCE($1, sync_token),
        last_synced_at = now(),
        updated_at     = now()
    WHERE id = $2
  `, [nextSyncToken, cal.id]);

  const statLine = Object.entries(stats)
    .filter(([, v]) => v > 0)
    .map(([k, v]) => `${k}=${v}`)
    .join(' ') || 'no-changes';
  console.log(`  ${mode} sync ok: ${statLine}`);
}

// ─── Entry point ──────────────────────────────────────────────────────
(async () => {
  const pg = new Pool(DB);
  const t0 = Date.now();
  try {
    const { rows: cals } = await pg.query(`
      SELECT id, google_id, role, sync_token
      FROM gcal_calendars
      ORDER BY id
    `);
    if (!cals.length) {
      console.error('gcal-sync: no rows in gcal_calendars — did migration 119 run?');
      process.exit(3);
    }
    for (const cal of cals) {
      await syncCalendar(pg, cal);
    }
  } finally {
    await pg.end();
  }
  console.log(`\ngcal-sync: done in ${((Date.now() - t0) / 1000).toFixed(2)}s`);
})().catch(err => {
  console.error('gcal-sync failed:', err.errors || err.stack || err.message || err);
  process.exit(1);
});
