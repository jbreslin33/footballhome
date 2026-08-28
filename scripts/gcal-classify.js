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
//   * Pass C (migrateSplitSeriesRsvps) handles a Google Calendar quirk:
//     editing a recurring event's time as "this and following" doesn't
//     move the existing series — it cancels it and mints a brand new
//     series with a new master event id. gcal-sync.js mirrors that
//     correctly (tombstone old, insert new), but with nothing to carry
//     RSVPs across the split they'd otherwise vanish. This pass detects
//     same-day/same-summary/same-location tombstone→live pairs on the
//     same calendar and copies RSVPs/attendance forward. Idempotent
//     (ON CONFLICT DO NOTHING), safe to run every tick.
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
    regex:    '^Soccer[[:space:]]+.*[[:space:]]+vs[[:space:]]+',
    kind:     'match',
    category: 'mens',
    note:     'Mens match or friendly with an opponent',
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
// Applies to kind IN ('pickup','practice') — the weekly-cadence
// events. Mens currently has 3 practices Wed/Thu/Fri and 2 pickups
// Tue/Sat; the Sunday 20:00 rule opens the whole week together so
// players commit to their week in one sitting. match/meeting/camp get
// NULL until §6.5.4 specifies their windows.
const RSVPS_OPEN_AT_SQL = `
  CASE WHEN $2 IN ('pickup','practice') THEN
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

// A schedule-tag param (e.g. $7, holding "17:15:00" or NULL) is a bare
// time-of-day; combine it with the gcal event's own local start date
// (America/New_York) to get the timestamptz to store. NULL propagates
// through the ::time cast and the arithmetic, so no CASE needed.
function scheduleTagSql(paramRef) {
  return `(date_trunc('day', ge.starts_at AT TIME ZONE 'America/New_York') + ${paramRef}::time) AT TIME ZONE 'America/New_York'`;
}

// ─── Classify one pattern ─────────────────────────────────────────────
// Returns { inserted, updated, unchanged } stats.
async function classifyPattern(pg, p) {
  // Guard so an earlier pattern in the table wins if two overlap: skip
  // rows whose fh_events row already has a DIFFERENT kind set. (Same
  // kind/category → normal UPSERT path, may still refresh
  // rsvps_open_at if the event was rescheduled.)
  //
  // Also skip events that carry a `Team:` tag in their description —
  // those are owned by the §6.1.5 DSL classifier (see classifyDsl
  // below). Disjoint sets: an event either has DSL tags OR falls to
  // the summary-regex legacy path, never both.
  const sql = `
    WITH candidates AS (
      SELECT ge.id AS gcal_event_id
      FROM   gcal_events ge
      LEFT JOIN fh_events fe ON fe.gcal_event_id = ge.id
      WHERE  ge.deleted_at IS NULL
        AND  ge.summary ~* $1
        AND  (ge.description IS NULL OR ge.description !~* '\\mteam[[:space:]]*:')
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
  // suppressed the write. Count separately for reporting. Same Team:
  // exclusion as the candidates CTE — otherwise DSL-owned events
  // would inflate the "matched" number.
  const totalMatch = await pg.query(`
    SELECT COUNT(*)::int AS n
    FROM   gcal_events ge
    WHERE  ge.deleted_at IS NULL AND ge.summary ~* $1
      AND  (ge.description IS NULL OR ge.description !~* '\\mteam[[:space:]]*:')
  `, [p.regex]);
  const unchanged = totalMatch.rows[0].n - row.inserted - row.updated;
  return { ...row, unchanged, matched: totalMatch.rows[0].n };
}

// ─── §6.1.5 DSL classifier ────────────────────────────────────────────
//
// Reads the description body of every non-tombstoned gcal_events row
// that contains a `Team:` marker, parses the tag DSL, resolves each
// (Club, Team) pair against gcal_team_aliases → teams.id, then upserts
// fh_events + rebuilds fh_event_teams so the junction reflects the
// current description exactly.
//
// Supported tags (case-insensitive, one per line, tag: value):
//
//   Team:    Pickup | Practice | APSL | Liga 1 | Liga 2 | Adult | ...
//   Club:    Mens   | Womens   | Boys | Girls        (list-friendly)
//   Type:    Practice | Pickup | Match | Meeting | Camp | Other | Barn Night
//                                                              (alias: Kind:)
//   Home:    Yes    | No       | Neutral                          (matches only)
//   Opponent: free-form opponent name                          (matches only)
//   Notes:   free-form text; stored in fh_events.fh_notes verbatim.
//
// Team + Club are lists-of-values: either comma-separated on one line
// (`Club: Mens, Womens`) or repeated across lines. All Team values
// cross-product with all Club values to produce (club, team) pairs;
// each pair looks up gcal_team_aliases → team_id and adds one
// fh_event_teams row.
//
// Values are normalized internally, so `Type: Match` and `Type: match`
// classify the same way. Use Title Case in Google Calendar descriptions.
//
// Derivation rules when Type: is not explicit:
//   * If any resolved team_alias is 'pickup'    → kind='pickup'
//   * Else if any resolved team_alias is 'practice' → kind='practice'
//   * Else → kind='match'
//
// Category (single-value cache on fh_events, mostly for filters/UI):
//   * Exactly one distinct club → category = that club
//   * Multiple distinct clubs → category = NULL (junction is truth)
//
// Idempotent: safe to re-run any number of times. Per-event work is
// wrapped in a transaction so a mid-loop crash cannot leave the
// junction half-rebuilt.

// JS mirror of migration 121's gcal_norm_alias() SQL function.
// Kept in this file (rather than imported from a shared helper)
// because gcal-classify.js is deliberately zero-dep-on-app-code so it
// can be run as a cron/systemd oneshot without pulling backend build
// artifacts.
function jsNormAlias(s) {
  if (s == null) return '';
  return String(s)
    .toLowerCase()
    .replace(/[^a-z0-9 ]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

// Parse one description body into a tag bundle. Returns:
//   { teams: string[], clubs: string[], kind: string|null,
//     isHome: boolean|null, opponent: string|null, notes: string|null }
// All returned strings are POST-normalized via jsNormAlias EXCEPT
// notes (rendered verbatim to fh_events.fh_notes). Empty arrays are
// possible: a description with `Notes:` but no Team: is legal — the
// legacy classifier or a later manual classification handles kind.
// Parses a bare time-of-day value ("5:15pm", "5pm", "17:15", "5:15 PM")
// into a "HH:MI:SS" 24h string for casting to ::time in SQL. Returns
// null on anything unparseable — same "ignore silently" contract as an
// unrecognized Home: value, so a typo doesn't crash the classifier.
function parseTimeOfDay(raw) {
  if (raw == null) return null;
  const m = String(raw).trim().match(/^(\d{1,2})(?::(\d{2}))?\s*(am|pm)?$/i);
  if (!m) return null;
  let hour = parseInt(m[1], 10);
  const min = m[2] ? parseInt(m[2], 10) : 0;
  const ampm = m[3] ? m[3].toLowerCase() : null;
  if (min > 59) return null;
  if (ampm) {
    if (hour < 1 || hour > 12) return null;
    if (ampm === 'pm' && hour !== 12) hour += 12;
    if (ampm === 'am' && hour === 12) hour = 0;
  } else if (hour > 23) {
    return null;
  }
  return `${String(hour).padStart(2, '0')}:${String(min).padStart(2, '0')}:00`;
}

function parseDsl(description) {
  const out = {
    teams: [], clubs: [], kind: null, isHome: null, opponent: null, notes: null,
    startTime: null, endTime: null, arrivalTime: null, warmupTime: null,
    kickoffTime: null, gameEndTime: null, league: null,
  };
  if (!description) return out;

  // gcal often HTML-encodes the description into `<br>`-separated
  // spans when the user pastes newlines through the web UI. Normalize
  // to plain-line form first: strip HTML tags, decode a small set of
  // entities, then split on newline.
  const plain = description
    .replace(/<br\s*\/?>/gi, '\n')
    .replace(/<\/?[a-z][^>]*>/gi, '')
    .replace(/&nbsp;/gi, ' ')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'");

  for (const raw of plain.split(/\r?\n/)) {
    const m = raw.match(/^\s*([A-Za-z]+)\s*:\s*(.*?)\s*$/);
    if (!m) continue;
    const tag = m[1].toLowerCase();
    const val = m[2];
    if (val === '') continue;

    switch (tag) {
      case 'team':
        for (const v of val.split(',')) {
          const n = jsNormAlias(v);
          if (n) out.teams.push(n);
        }
        break;
      case 'club':
        for (const v of val.split(',')) {
          const n = jsNormAlias(v);
          if (n) out.clubs.push(n);
        }
        break;
      case 'type':
      case 'kind': {
        let n = jsNormAlias(val);
        // "Intra Squad", "Intra-Squad" and "IntraSquad" all normalize to
        // either "intra squad" or "intrasquad" depending on how ops typed
        // it; only the one-word form is a legal kind (migration 317), so
        // fold the spaced spelling onto it rather than silently dropping
        // the tag and inferring 'match' — which is exactly the fallback
        // that made two intra-squad games look like two real fixtures.
        if (n === 'intra squad') n = 'intrasquad';
        // Accept only values the CHECK constraint allows.
        if (['practice','pickup','match','meeting','camp','other','barn night','intrasquad'].includes(n)) {
          out.kind = n;
        }
        break;
      }
      case 'home': {
        const n = jsNormAlias(val);
        if (n === 'yes' || n === 'true' || n === 'home')   out.isHome = true;
        else if (n === 'no' || n === 'false' || n === 'away') out.isHome = false;
        else if (n === 'neutral') out.isHome = null;
        break;
      }
      case 'opponent':
        out.opponent = out.opponent == null ? val : (out.opponent + ' ' + val);
        break;
      // Free-form league label (2026-08-22, migration 297) — e.g. "CASA
      // Select Liga 1" or "APSL Delaware River" — the authoritative
      // signal for which league/division badge a match's social post
      // graphic should show, instead of guessing from the opponent's
      // scraped team name. Preserved verbatim like Opponent:/Notes:.
      case 'league':
        out.league = out.league == null ? val : (out.league + ' ' + val);
        break;
      case 'notes':
        // Preserve exact user text — no normalize. Multiple `Notes:`
        // lines concatenate with newline separators.
        out.notes = out.notes == null ? val : (out.notes + '\n' + val);
        break;
      // Schedule tags (§6.1.5 addendum). Each is a bare time-of-day —
      // the date always comes from the gcal event's own local start
      // date, applied where these are combined into a timestamptz.
      case 'start':
        out.startTime = parseTimeOfDay(val);
        break;
      case 'end':
        out.endTime = parseTimeOfDay(val);
        break;
      case 'arrival':
        out.arrivalTime = parseTimeOfDay(val);
        break;
      case 'warmup':
        out.warmupTime = parseTimeOfDay(val);
        break;
      case 'kickoff':
        out.kickoffTime = parseTimeOfDay(val);
        break;
      case 'gameend':
        out.gameEndTime = parseTimeOfDay(val);
        break;
      // Unknown tag → ignore silently (forward-compat with future tags).
    }
  }

  // De-dupe while preserving first-seen order.
  out.teams = [...new Set(out.teams)];
  out.clubs = [...new Set(out.clubs)];
  return out;
}

// Load the entire alias table into an in-memory Map keyed by
// `${club}|${team}`. Table is small (≤ ~50 rows), so per-event queries
// aren't worth the round-trips.
async function loadAliases(pg) {
  const { rows } = await pg.query(`
    SELECT gta.club_alias,
           gta.team_alias,
           gta.team_id,
           t.gender_category
    FROM   gcal_team_aliases gta
    JOIN   teams t ON t.id = gta.team_id
  `);
  const map = new Map();
  for (const r of rows) {
    map.set(`${r.club_alias}|${r.team_alias}`, {
      teamId:   r.team_id,
      category: r.gender_category,   // 'mens' | 'womens' | 'boys' | 'girls'
    });
  }
  return map;
}

// Classify all DSL-tagged events. Returns aggregate stats.
async function classifyDsl(pg) {
  const stats = {
    scanned:     0,   // events with a Team: marker
    resolved:    0,   // events that produced ≥1 (club,team) pair
    upserted:    0,   // events whose fh_events row was written or updated
    linksAdded:  0,
    linksRemoved:0,
    unresolved:  [],  // { gcalEventId, summary, pairs: ['mens|xyz', ...] }
    missingClub: [],  // { gcalEventId, summary, teams: [...] }
    missingTeam: [],  // { gcalEventId, summary, clubs: [...] }
  };

  const aliases = await loadAliases(pg);

  // Pull every candidate row with description body + summary for logs.
  // The description ~* '\mteam[[:space:]]*:' regex mirrors the
  // exclusion in classifyPattern so the two paths are truly disjoint.
  const { rows: events } = await pg.query(`
    SELECT ge.id, ge.summary, ge.description
    FROM   gcal_events ge
    WHERE  ge.deleted_at IS NULL
      AND  ge.description ~* '\\mteam[[:space:]]*:'
    ORDER BY ge.id
  `);

  for (const ev of events) {
    stats.scanned += 1;
    const dsl = parseDsl(ev.description);

    // A description with only `Notes:` or only `Home:` (no Team:) is
    // legal — but this DSL pass only exists to establish team links,
    // so with zero teams we bail. That event falls to the legacy
    // regex classifier (which we already excluded via description
    // regex, so it actually falls through to unclassifiedReport).
    if (dsl.teams.length === 0) continue;

    // Club is required whenever Team is present — otherwise there's
    // no way to resolve to a specific teams row.
    if (dsl.clubs.length === 0) {
      stats.missingClub.push({ gcalEventId: ev.id, summary: ev.summary, teams: dsl.teams });
      continue;
    }

    // Cross-product Club × Team → alias lookups.
    const resolved  = [];   // { teamId, category, clubAlias, teamAlias }
    const unresolved = [];
    for (const club of dsl.clubs) {
      for (const team of dsl.teams) {
        const key = `${club}|${team}`;
        const hit = aliases.get(key);
        if (hit) {
          resolved.push({ teamId: hit.teamId, category: hit.category, clubAlias: club, teamAlias: team });
        } else {
          unresolved.push(key);
        }
      }
    }

    if (resolved.length === 0) {
      stats.unresolved.push({ gcalEventId: ev.id, summary: ev.summary, pairs: unresolved });
      continue;
    }

    stats.resolved += 1;

    // Derive kind: explicit Type: wins; else infer from team_alias.
    let kind = dsl.kind;
    if (!kind) {
      const someTeamAlias = new Set(resolved.map(r => r.teamAlias));
      if      (someTeamAlias.has('pickup'))   kind = 'pickup';
      else if (someTeamAlias.has('practice')) kind = 'practice';
      else                                    kind = 'match';
    }

    // Derive category: unique category across resolved teams, else NULL.
    const cats = new Set(resolved.map(r => r.category));
    const category = cats.size === 1 ? [...cats][0] : null;

    const teamIds = [...new Set(resolved.map(r => r.teamId))];

    // ─── Per-event transaction: upsert fh_events + rebuild junction ───
    const client = await pg.connect();
    try {
      await client.query('BEGIN');

      // Upsert fh_events. WHERE IS DISTINCT clause suppresses updated_at
      // churn when nothing meaningfully changed.
      const upsertSql = `
        WITH upsert AS (
          INSERT INTO fh_events (
            gcal_event_id, kind, category, is_home, opponent, fh_notes, rsvps_open_at,
            start_at, end_at, arrival_at, warmup_at, kickoff_at, game_end_at, league
          )
          SELECT $1, $2, $3, $4, $5, $6, ${RSVPS_OPEN_AT_SQL},
                 ${scheduleTagSql('$7')}, ${scheduleTagSql('$8')}, ${scheduleTagSql('$9')},
                 ${scheduleTagSql('$10')}, ${scheduleTagSql('$11')}, ${scheduleTagSql('$12')}, $13
          FROM   gcal_events ge
          WHERE  ge.id = $1
          ON CONFLICT (gcal_event_id) DO UPDATE SET
            kind          = EXCLUDED.kind,
            category      = EXCLUDED.category,
            is_home       = EXCLUDED.is_home,
            opponent      = EXCLUDED.opponent,
            fh_notes      = EXCLUDED.fh_notes,
            rsvps_open_at = EXCLUDED.rsvps_open_at,
            start_at      = EXCLUDED.start_at,
            end_at        = EXCLUDED.end_at,
            arrival_at    = EXCLUDED.arrival_at,
            warmup_at     = EXCLUDED.warmup_at,
            kickoff_at    = EXCLUDED.kickoff_at,
            game_end_at   = EXCLUDED.game_end_at,
            league        = EXCLUDED.league,
            updated_at    = now()
          WHERE fh_events.kind          IS DISTINCT FROM EXCLUDED.kind
             OR fh_events.category      IS DISTINCT FROM EXCLUDED.category
             OR fh_events.is_home       IS DISTINCT FROM EXCLUDED.is_home
             OR fh_events.opponent      IS DISTINCT FROM EXCLUDED.opponent
             OR fh_events.fh_notes      IS DISTINCT FROM EXCLUDED.fh_notes
             OR fh_events.rsvps_open_at IS DISTINCT FROM EXCLUDED.rsvps_open_at
             OR fh_events.start_at      IS DISTINCT FROM EXCLUDED.start_at
             OR fh_events.end_at        IS DISTINCT FROM EXCLUDED.end_at
             OR fh_events.arrival_at    IS DISTINCT FROM EXCLUDED.arrival_at
             OR fh_events.warmup_at     IS DISTINCT FROM EXCLUDED.warmup_at
             OR fh_events.kickoff_at    IS DISTINCT FROM EXCLUDED.kickoff_at
             OR fh_events.game_end_at   IS DISTINCT FROM EXCLUDED.game_end_at
             OR fh_events.league        IS DISTINCT FROM EXCLUDED.league
          RETURNING id
        )
        SELECT COALESCE((SELECT id FROM upsert),
                        (SELECT id FROM fh_events WHERE gcal_event_id = $1)) AS fh_event_id,
               EXISTS (SELECT 1 FROM upsert) AS wrote;
      `;
      const { rows: [upRow] } = await client.query(
        upsertSql,
        [
          ev.id, kind, category, dsl.isHome, dsl.opponent, dsl.notes,
          dsl.startTime, dsl.endTime, dsl.arrivalTime, dsl.warmupTime, dsl.kickoffTime, dsl.gameEndTime,
          dsl.league,
        ],
      );
      if (upRow.wrote) stats.upserted += 1;
      const fhEventId = upRow.fh_event_id;

      // Rebuild junction: DELETE rows not in desired set, INSERT
      // missing ones. Two-step keeps INSERT idempotent and DELETE
      // scoped narrowly (no wipe-and-refill nuke of RSVP relationships,
      // though junction has no dependents today).
      const { rowCount: removed } = await client.query(
        `DELETE FROM fh_event_teams
         WHERE  fh_event_id = $1
           AND  team_id <> ALL($2::int[])`,
        [fhEventId, teamIds],
      );
      stats.linksRemoved += removed;

      const { rowCount: added } = await client.query(
        `INSERT INTO fh_event_teams (fh_event_id, team_id)
         SELECT $1, t
         FROM   unnest($2::int[]) AS t
         ON CONFLICT (fh_event_id, team_id) DO NOTHING`,
        [fhEventId, teamIds],
      );
      stats.linksAdded += added;

      // Same reconcile for leagues (fh_event_leagues, migration 318).
      // Resolved from the raw `League:` tag through gcal_league_aliases
      // inside SQL rather than in JS, so the alias table stays the one
      // place a league name is recognised. Split on commas because one
      // event can belong to two leagues — intra-squad APSL vs Liga 1,
      // cross-league friendlies, cup ties.
      //
      // Rebuilt every pass, exactly like fh_event_teams: retagging an
      // event in Google has to be able to REMOVE a league, not just add
      // one, or a corrected tag leaves the old crest behind forever.
      await client.query(
        `DELETE FROM fh_event_leagues fel
          WHERE fel.fh_event_id = $1::bigint
            AND fel.organization_id <> ALL(
                  COALESCE((
                    SELECT array_agg(DISTINCT gla.organization_id)
                      FROM regexp_split_to_table(COALESCE($2::text,''), '[[:space:]]*,[[:space:]]*') AS tok
                      JOIN gcal_league_aliases gla
                        ON LOWER(BTRIM(gla.alias)) = LOWER(BTRIM(tok))
                  ), '{}'::int[]))`,
        [fhEventId, dsl.league],
      );
      const { rowCount: leaguesAdded } = await client.query(
        `INSERT INTO fh_event_leagues (fh_event_id, organization_id)
         SELECT DISTINCT $1::bigint, gla.organization_id
           FROM regexp_split_to_table(COALESCE($2::text,''), '[[:space:]]*,[[:space:]]*') AS tok
           JOIN gcal_league_aliases gla
             ON LOWER(BTRIM(gla.alias)) = LOWER(BTRIM(tok))
         ON CONFLICT DO NOTHING`,
        [fhEventId, dsl.league],
      );
      stats.leagueLinksAdded = (stats.leagueLinksAdded || 0) + leaguesAdded;

      await client.query('COMMIT');
    } catch (err) {
      await client.query('ROLLBACK');
      throw err;
    } finally {
      client.release();
    }
  }

  return stats;
}

// ─── Pass C: recurring-series-split RSVP/attendance carry-forward ─────
// When an admin edits a recurring event's time as "this and following"
// in Google Calendar, Google does NOT update the existing series in
// place — it cancels the old recurring series' future instances and
// mints a brand new series with a new master event id. gcal-sync.js
// faithfully mirrors that (tombstones the old gcal_events rows, inserts
// the new ones), which is correct, but it means RSVPs/attendance
// attached to the old (now-dead) fh_events row have nowhere to go and
// silently vanish from anyone's view.
//
// This pass detects that specific split pattern — same calendar, same
// summary, same location, same calendar day (America/New_York), a
// modest time shift (<=3h), and the new row appearing close in time to
// the old one being tombstoned (<=2 days, covers the normal case where
// both happen in the same sync tick) — and carries forward any RSVPs/
// attendance the old fh_events row had onto the new one. ON CONFLICT DO
// NOTHING means it never overwrites someone who already re-RSVP'd on
// the new event, and re-running this every 5 minutes is a no-op once a
// pair has been migrated.
async function migrateSplitSeriesRsvps(pg) {
  const stats = { pairs: 0, rsvpsMoved: 0, attendanceMoved: 0 };

  const { rows: pairs } = await pg.query(`
    SELECT old_fe.id AS old_fh_event_id, new_fe.id AS new_fh_event_id,
           old.id AS old_gcal_id, new.id AS new_gcal_id, new.starts_at
    FROM gcal_events old
    JOIN gcal_events new
      ON  new.calendar_id = old.calendar_id
      AND new.deleted_at IS NULL
      AND old.deleted_at IS NOT NULL
      AND new.google_event_id <> old.google_event_id
      AND new.summary IS NOT DISTINCT FROM old.summary
      AND new.location IS NOT DISTINCT FROM old.location
      AND (new.starts_at AT TIME ZONE 'America/New_York')::date
        = (old.starts_at AT TIME ZONE 'America/New_York')::date
      AND abs(extract(epoch FROM (new.starts_at - old.starts_at))) <= 3 * 3600
      AND abs(extract(epoch FROM (new.first_seen_at - old.deleted_at))) <= 2 * 86400
    JOIN fh_events old_fe ON old_fe.gcal_event_id = old.id
    JOIN fh_events new_fe ON new_fe.gcal_event_id = new.id
    ORDER BY new.starts_at
  `);
  stats.pairs = pairs.length;

  for (const p of pairs) {
    const rsvpRes = await pg.query(`
      INSERT INTO fh_event_rsvps (fh_event_id, person_id, response, responded_at, created_via)
      SELECT $2, r.person_id, r.response, r.responded_at, r.created_via
      FROM fh_event_rsvps r
      WHERE r.fh_event_id = $1
      ON CONFLICT (fh_event_id, person_id) DO NOTHING
    `, [p.old_fh_event_id, p.new_fh_event_id]);
    stats.rsvpsMoved += rsvpRes.rowCount;

    const attRes = await pg.query(`
      INSERT INTO fh_event_attendance (fh_event_id, person_id, status, marked_by_user_id, marked_at)
      SELECT $2, a.person_id, a.status, a.marked_by_user_id, a.marked_at
      FROM fh_event_attendance a
      WHERE a.fh_event_id = $1
      ON CONFLICT (fh_event_id, person_id) DO NOTHING
    `, [p.old_fh_event_id, p.new_fh_event_id]);
    stats.attendanceMoved += attRes.rowCount;

    if (rsvpRes.rowCount || attRes.rowCount) {
      console.log(
        `  carried forward: gcal ${p.old_gcal_id} -> ${p.new_gcal_id}` +
        ` (fh_event ${p.old_fh_event_id} -> ${p.new_fh_event_id}, starts_at=${p.starts_at.toISOString()})` +
        ` rsvps=${rsvpRes.rowCount} attendance=${attRes.rowCount}`
      );
    }
  }

  return stats;
}

// ─── Report soccer-prefixed rows nothing matched ──────────────────────
// These are the Slice 8 "admin classification queue" candidates.
// Excludes events that carry a `Team:` marker in their description —
// those are the DSL classifier's territory and any resolution failure
// gets its own richer report from classifyDsl (missingClub /
// missingTeam / unresolved buckets).
async function unclassifiedReport(pg) {
  const patternUnion = PATTERNS.map((_, i) => `ge.summary ~* $${i + 1}`).join(' OR ');
  const args = PATTERNS.map(p => p.regex);
  const sql = `
    SELECT ge.summary, COUNT(*)::int AS n
    FROM   gcal_events ge
    WHERE  ge.deleted_at IS NULL
      AND  ge.summary ~* '^Soccer\\M'
      AND  (ge.description IS NULL OR ge.description !~* '\\mteam[[:space:]]*:')
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
    // ─── Pass A: §6.1.5 DSL classifier ────────────────────────────────
    // Runs first because it's the source-of-truth path. Legacy regex
    // pass below only touches events without a `Team:` marker.
    console.log(`gcal-classify: DSL pass (§6.1.5)`);
    const ds = await classifyDsl(pg);
    console.log(
      `  scanned=${ds.scanned} resolved=${ds.resolved} upserted=${ds.upserted}` +
      ` links+=${ds.linksAdded} links-=${ds.linksRemoved}`
    );
    if (ds.missingClub.length) {
      console.log(`  ${ds.missingClub.length} event(s) have Team: but no Club: tag`);
      for (const m of ds.missingClub) {
        console.log(`    gcal_event_id=${m.gcalEventId}  ${m.summary}  teams=[${m.teams.join(', ')}]`);
      }
    }
    if (ds.unresolved.length) {
      console.log(`  ${ds.unresolved.length} event(s) have (club,team) pairs missing from gcal_team_aliases:`);
      for (const u of ds.unresolved) {
        console.log(`    gcal_event_id=${u.gcalEventId}  ${u.summary}  pairs=[${u.pairs.join(' ; ')}]`);
      }
      console.log(`    (add rows to gcal_team_aliases — see migration 121 for shape)`);
    }

    // ─── Pass B: legacy §6.1 summary-regex classifier ─────────────────
    console.log(`\ngcal-classify: legacy regex pass (§6.1) — ${PATTERNS.length} pattern(s)`);
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
      console.log(`\ngcal-classify: ${unclassified.length} unique Soccer* summaries (no Team: tag) do NOT match any pattern:`);
      for (const u of unclassified) {
        console.log(`  ${String(u.n).padStart(4)}  ${u.summary}`);
      }
      console.log('  (add DSL tags in the gcal description, OR add a row to PATTERNS at the top of this file)');
    } else {
      console.log(`\ngcal-classify: every soccer-prefixed event has a classifier match`);
    }

    // ─── Pass C: carry forward RSVPs/attendance across recurring-series splits ───
    console.log(`\ngcal-classify: recurring-series-split carry-forward pass`);
    const sp = await migrateSplitSeriesRsvps(pg);
    console.log(`  pairs=${sp.pairs} rsvps-moved=${sp.rsvpsMoved} attendance-moved=${sp.attendanceMoved}`);

    console.log(
      `\ngcal-classify: totals` +
      ` dsl-upserted=${ds.upserted}` +
      ` legacy-inserted=${totalInserted} legacy-updated=${totalUpdated} legacy-unchanged=${totalUnchanged}` +
      ` split-rsvps-moved=${sp.rsvpsMoved}` +
      `  (${((Date.now() - t0) / 1000).toFixed(2)}s)`
    );
  } finally {
    await pg.end();
  }
})().catch(err => {
  console.error('gcal-classify failed:', err.stack || err.message || err);
  process.exit(1);
});
