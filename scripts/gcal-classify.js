#!/usr/bin/env node
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// scripts/gcal-classify.js — promote gcal_events → fh_events (Slice 3)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
//
// After scripts/gcal-sync.js has mirrored Google's calendars into
// gcal_events, this script reads the soccer-prefixed rows (see
// docs/calendar-design.md §6.0) and populates fh_events per the
// §6.1 pattern table.
//
// One-shot script. Systemd's gcal-sync.service runs it as its second
// ExecStart line, so every 5-min tick does sync → classify.
//
// Design notes:
//
//   * The §6.1 pattern table lives at the top of this file as an
//     array. Adding a new classification rule = one entry here.
//
//   * We iterate the table and run one UPSERT per pattern. This is
//     simpler than a single mega-CASE statement and gives per-pattern
//     stats.
//
//   * For kind='pickup', rsvps_open_at is computed in SQL from
//     starts_at (America/New_York), using the "most recent Sunday
//     20:00 ET that is <= starts_at" rule from §6.5.1. Postgres AT
//     TIME ZONE handles DST correctly.
//
//   * ON CONFLICT DO UPDATE ... WHERE ... IS DISTINCT FROM avoids
//     bumping updated_at for rows whose classification hasn't
//     actually changed. This keeps the "manual admin classification"
//     Slice 8 story clean — if an admin bumped updated_at on
//     fh_events, we know they did it, not the classifier.
//
//   * We do NOT touch fh_events rows whose gcal_events parent is
//     tombstoned. RSVPs must survive tombstone/undelete per §1.1;
//     if the gcal_events row resurrects, the next classifier run
//     will see deleted_at=NULL again and refresh the classification.
//
//   * We do NOT delete fh_events rows for events that stopped
//     matching a pattern (e.g. someone renamed "Soccer 11th grade+
//     Practice" to "Basketball Practice"). Instead, log them at the
//     end so the operator can manually intervene. Deleting would
//     lose attached RSVPs.
//
// Run: node scripts/gcal-classify.js
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

require('dotenv').config({ path: __dirname + '/../env' });
const { Pool } = require('pg');

// ─── §6.1 pattern table ───────────────────────────────────────────────
// regex     — Postgres POSIX ARE (so [[:space:]] not \s, \M/\y not \b).
// kind      — matches the fh_events.kind CHECK constraint.
// category  — matches the fh_events.category CHECK constraint, or null.
//
// Add rows here. Order matters when patterns could overlap — first
// matching pattern wins (implemented via NOT EXISTS guard).
const PATTERNS = [
  {
    regex:    '^Soccer[[:space:]]+11th[[:space:]]+grade\\+',
    kind:     'pickup',
    category: 'mens',
    note:     'Saturday Mens Pickup — the §6.5 windowed-RSVP flagship case',
  },
  {
    regex:    '^Soccer[[:space:]]+All[[:space:]]+Staff[[:space:]]+Meeting',
    kind:     'meeting',
    category: 'staff',
    note:     'Recurring staff meeting on Soccer cal',
  },
];

// ─── DB ───────────────────────────────────────────────────────────────
const DB = {
  host:     process.env.PGHOST     || 'localhost',
  port:     parseInt(process.env.PGPORT || '5432', 10),
  database: process.env.PGDATABASE || 'footballhome',
  user:     process.env.PGUSER     || 'footballhome_user',
  password: process.env.PGPASSWORD || 'footballhome_pass',
};

// ─── RSVP-window SQL fragment ─────────────────────────────────────────
// Given ge.starts_at (TIMESTAMPTZ), returns the TIMESTAMPTZ of the
// most recent Sunday 20:00 America/New_York that is <= starts_at.
// Sunday itself before 8pm rolls back to the *prior* Sunday.
//
// Only meaningful for kind='pickup' today; other kinds get NULL.
const RSVPS_OPEN_AT_SQL = `
  CASE WHEN $2 = 'pickup' THEN
    (
      date_trunc('day', ge.starts_at AT TIME ZONE 'America/New_York')
      - (
          CASE
            WHEN EXTRACT(DOW  FROM ge.starts_at AT TIME ZONE 'America/New_York')::int = 0
             AND EXTRACT(HOUR FROM ge.starts_at AT TIME ZONE 'America/New_York')::int < 20
            THEN INTERVAL '7 days'
            ELSE EXTRACT(DOW  FROM ge.starts_at AT TIME ZONE 'America/New_York')::int * INTERVAL '1 day'
          END
        )
      + INTERVAL '20 hours'
    ) AT TIME ZONE 'America/New_York'
  ELSE NULL END
`;

// ─── Classify one pattern ─────────────────────────────────────────────
// Returns { inserted, updated, unchanged } stats.
async function classifyPattern(pg, p) {
  // Guard so an earlier pattern in the table wins if two overlap: skip
  // rows whose fh_events row already has a DIFFERENT kind set. (Same
  // kind/category → normal UPSERT path, may still refresh
  // rsvps_open_at if the event was rescheduled.)
  const sql = `
    WITH candidates AS (
      SELECT ge.id AS gcal_event_id
      FROM   gcal_events ge
      LEFT JOIN fh_events fe ON fe.gcal_event_id = ge.id
      WHERE  ge.deleted_at IS NULL
        AND  ge.summary ~* $1
        AND  (fe.id IS NULL OR (fe.kind = $2 AND (fe.category IS NOT DISTINCT FROM $3)))
    ),
    upsert AS (
      INSERT INTO fh_events (gcal_event_id, kind, category, rsvps_open_at)
      SELECT c.gcal_event_id, $2, $3, ${RSVPS_OPEN_AT_SQL}
      FROM   candidates c
      JOIN   gcal_events ge ON ge.id = c.gcal_event_id
      ON CONFLICT (gcal_event_id) DO UPDATE SET
        kind          = EXCLUDED.kind,
        category      = EXCLUDED.category,
        rsvps_open_at = EXCLUDED.rsvps_open_at,
        updated_at    = now()
      WHERE fh_events.kind          IS DISTINCT FROM EXCLUDED.kind
         OR fh_events.category      IS DISTINCT FROM EXCLUDED.category
         OR fh_events.rsvps_open_at IS DISTINCT FROM EXCLUDED.rsvps_open_at
      RETURNING (xmax = 0) AS inserted
    )
    SELECT
      COUNT(*) FILTER (WHERE inserted)       ::int AS inserted,
      COUNT(*) FILTER (WHERE NOT inserted)   ::int AS updated
    FROM upsert;
  `;
  const { rows: [row] } = await pg.query(sql, [p.regex, p.kind, p.category]);

  // "Unchanged" = matched the pattern but the WHERE-IS-DISTINCT filter
  // suppressed the write. Count separately for reporting.
  const totalMatch = await pg.query(`
    SELECT COUNT(*)::int AS n
    FROM   gcal_events ge
    WHERE  ge.deleted_at IS NULL AND ge.summary ~* $1
  `, [p.regex]);
  const unchanged = totalMatch.rows[0].n - row.inserted - row.updated;
  return { ...row, unchanged, matched: totalMatch.rows[0].n };
}

// ─── Report soccer-prefixed rows nothing matched ──────────────────────
// These are the Slice 8 "admin classification queue" candidates.
async function unclassifiedReport(pg) {
  const patternUnion = PATTERNS.map((_, i) => `ge.summary ~* $${i + 1}`).join(' OR ');
  const args = PATTERNS.map(p => p.regex);
  const sql = `
    SELECT ge.summary, COUNT(*)::int AS n
    FROM   gcal_events ge
    WHERE  ge.deleted_at IS NULL
      AND  ge.summary ~* '^Soccer\\M'
      AND  NOT (${patternUnion})
    GROUP BY ge.summary
    ORDER BY n DESC, ge.summary
    LIMIT 20;
  `;
  const { rows } = await pg.query(sql, args);
  return rows;
}

// ─── Entry point ──────────────────────────────────────────────────────
(async () => {
  const pg = new Pool(DB);
  const t0 = Date.now();
  try {
    console.log(`gcal-classify: ${PATTERNS.length} pattern(s) in table`);
    let totalInserted = 0, totalUpdated = 0, totalUnchanged = 0;

    for (const p of PATTERNS) {
      const r = await classifyPattern(pg, p);
      totalInserted  += r.inserted;
      totalUpdated   += r.updated;
      totalUnchanged += r.unchanged;
      console.log(
        `  [${p.kind}/${p.category ?? '-'}] ${p.regex}` +
        `\n    matched=${r.matched} inserted=${r.inserted} updated=${r.updated} unchanged=${r.unchanged}`
      );
    }

    const unclassified = await unclassifiedReport(pg);
    if (unclassified.length) {
      console.log(`\ngcal-classify: ${unclassified.length} unique Soccer* summaries do NOT match any pattern:`);
      for (const u of unclassified) {
        console.log(`  ${String(u.n).padStart(4)}  ${u.summary}`);
      }
      console.log('  (add a row to PATTERNS at the top of this file to classify them)');
    } else {
      console.log(`\ngcal-classify: every soccer-prefixed event has a pattern match`);
    }

    console.log(
      `\ngcal-classify: totals inserted=${totalInserted} updated=${totalUpdated} unchanged=${totalUnchanged}`
      + `  (${((Date.now() - t0) / 1000).toFixed(2)}s)`
    );
  } finally {
    await pg.end();
  }
})().catch(err => {
  console.error('gcal-classify failed:', err.stack || err.message || err);
  process.exit(1);
});
