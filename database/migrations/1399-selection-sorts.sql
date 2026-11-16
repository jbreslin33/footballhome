-- 1399 (2026-11-16): #teams sorts for picking a squad — 📊 Attendance,
-- 🧪 Trials, ⭐ Score (owner: "we need to be able to sort by various
-- things. by dues. by attendance. by attendance at the 'trial', by a
-- combined dues, attendance, trials attendance algorithm" → "give equal
-- weight for now").  💰 Paid status (mig 1275) stays the dues sort.
--
--   Attendance = practices he went to ÷ practices on his teams while he
--     was on them, club year so far (Aug 1 → now, window_start_month).
--     Trials are left out of it.  Games are left out (who plays a game is
--     the coach's pick, not the kid's attendance).
--   Trials = trial sessions he went to ÷ trial sessions held on his teams.
--     A trial is a practice whose calendar title matches
--     trial_title_pattern ("Soccer Indoor Travel Trials …").
--   "Went" = the awards rule (fh_award_candidates): attendance taken →
--     present/late; no attendance taken → he said Yes.
--   Score = weighted average of trials, attendance and dues (each 0–1),
--     ×100; a part with nothing to measure (no trials held yet) drops out
--     and the rest share its weight.  Dues 1 = paid up, losing
--     1/dues_months_to_zero per month behind; no LA registration = 0.
--     Dues are scored on the board from the same balance the card's dues
--     pill shows (RosterScreenBase).

BEGIN;

CREATE TABLE IF NOT EXISTS selection_score_policies (
    id                  serial PRIMARY KEY,
    club_id             integer NOT NULL REFERENCES clubs(id),
    trials_weight       numeric NOT NULL CHECK (trials_weight >= 0),
    attendance_weight   numeric NOT NULL CHECK (attendance_weight >= 0),
    dues_weight         numeric NOT NULL CHECK (dues_weight >= 0),
    dues_months_to_zero numeric NOT NULL DEFAULT 2 CHECK (dues_months_to_zero > 0),
    trial_title_pattern text    NOT NULL,
    window_start_month  smallint NOT NULL DEFAULT 8 CHECK (window_start_month BETWEEN 1 AND 12),
    effective_from      date    NOT NULL DEFAULT CURRENT_DATE,
    notes               text
);

INSERT INTO selection_score_policies (club_id, trials_weight, attendance_weight, dues_weight, dues_months_to_zero,
                                      trial_title_pattern, window_start_month, effective_from, notes)
SELECT 134, 1, 1, 1, 2, 'travel trials', 8, '2026-11-16', 'owner 11/16: "give equal weight for now"'
 WHERE NOT EXISTS (SELECT 1 FROM selection_score_policies WHERE club_id = 134);

CREATE OR REPLACE FUNCTION fh_selection_scores(p_person_ids integer[])
RETURNS TABLE (person_id integer, attended integer, expected integer, trials integer, trials_held integer)
LANGUAGE sql STABLE AS $$
  WITH pol AS (
    SELECT * FROM selection_score_policies WHERE club_id = 134 AND effective_from <= CURRENT_DATE
     ORDER BY effective_from DESC LIMIT 1
  ), w AS (
    SELECT make_timestamptz(extract(year FROM (now() AT TIME ZONE 'America/New_York')
                                              - make_interval(months => pol.window_start_month - 1))::int,
                            pol.window_start_month, 1, 0, 0, 0, 'America/New_York') AS from_at,
           pol.trial_title_pattern AS pat
      FROM pol
  ), ev AS MATERIALIZED (   -- his teams' past practices, only while he was on the team
    SELECT DISTINCT tp.person_id, e.id AS event_id, (g.summary ~* w.pat) AS is_trial
      FROM team_persons tp
      JOIN fh_event_teams et ON et.team_id = tp.team_id
      JOIN fh_events e       ON e.id = et.fh_event_id AND e.kind = 'practice'
      JOIN gcal_events g     ON g.id = e.gcal_event_id
      , w
     WHERE tp.person_id = ANY (p_person_ids)
       AND g.starts_at >= w.from_at AND g.starts_at < now()
       AND g.deleted_at IS NULL AND COALESCE(g.status, '') <> 'cancelled'
       AND (tp.joined_at IS NULL OR tp.joined_at < '1971-01-01' OR g.starts_at >= date_trunc('day', tp.joined_at))
       AND (tp.removed_at IS NULL OR g.starts_at < tp.removed_at)
  ), went AS (
    SELECT ev.person_id, ev.is_trial,
           CASE WHEN EXISTS (SELECT 1 FROM fh_event_attendance a WHERE a.fh_event_id = ev.event_id)
                THEN EXISTS (SELECT 1 FROM fh_event_attendance a WHERE a.fh_event_id = ev.event_id
                               AND a.person_id = ev.person_id AND a.status IN ('present', 'late'))
                ELSE EXISTS (SELECT 1 FROM fh_event_rsvps v WHERE v.fh_event_id = ev.event_id
                               AND v.person_id = ev.person_id AND v.response = 'yes') END AS went
      FROM ev
  )
  SELECT person_id,
         count(*) FILTER (WHERE went AND NOT is_trial)::int,
         count(*) FILTER (WHERE NOT is_trial)::int,
         count(*) FILTER (WHERE went AND is_trial)::int,
         count(*) FILTER (WHERE is_trial)::int
    FROM went GROUP BY person_id
$$;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('board_sort_attendance', 'Team boards sort pill — practice attendance',          '📊 Attendance', 1038),
    ('board_sort_trials',     'Team boards sort pill — trial sessions attended',      '🧪 Trials',     1039),
    ('board_sort_score',      'Team boards sort pill — trials + attendance + dues',   '⭐ Score',      1040),
    ('board_chip_attendance', 'Card chip under 📊 sort ({went} {of})',                '📊 {went}/{of}', 1041),
    ('board_chip_trials',     'Card chip under 🧪 sort ({went} {of})',                '🧪 {went}/{of}', 1042),
    ('board_chip_score',      'Card chip under ⭐ sort ({score})',                    '⭐ {score}',     1043),
    ('board_chip_score_tip',  'Hover on the ⭐ chip ({trials} {attendance} {dues})',  'Trials {trials} · Attendance {attendance} · Dues {dues}', 1044),
    ('board_chip_none_tip',   'Hover when there is nothing to measure yet',          'Nothing to measure yet', 1045)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);

COMMIT;
