-- 1263: #awards for youth AND adults, with slots and suggested players
-- (owner 2026-11-11: "start thinking of awards for award page and putting
-- players in the slots" / "for youth and adult").
--
-- award_types gains:
--   audience  youth · adult · all — which teams show the award
--             (youth = boys/girls teams, adult = mens/womens)
--   slots     how many winners a team gets (All-Star 3, the rest 1)
--   metric    NULL = coach's pick; else the stat that suggests a player:
--               attendance   practices + games attended, most first
--               appearances  games attended
--               keeper       games attended by a keeper (players.is_keeper)
--               newcomer     joined the team this season, most attended
--   blurb     one line saying what the award is for (shown on the page)
--
-- fh_award_candidates(term, year) — per team, per metric award, the
-- players ranked by that stat inside the season window (the term's start
-- to the next term's start, never past now).  Attendance marks win; a
-- team with no marks of a kind in the window (Women, most youth games)
-- falls back, per event, to "said yes" RSVPs where nobody took attendance
-- (basis attendance · mixed · rsvp says which).  Ties share a rank.  These
-- are SUGGESTIONS: the page shows #1 dashed in the slot, a tap gives it.
ALTER TABLE award_types
  ADD COLUMN IF NOT EXISTS audience text NOT NULL DEFAULT 'all',
  ADD COLUMN IF NOT EXISTS slots    int  NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS metric   text,
  ADD COLUMN IF NOT EXISTS blurb    text;

DO $$ BEGIN
  ALTER TABLE award_types ADD CONSTRAINT award_types_audience_check CHECK (audience IN ('youth', 'adult', 'all'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TABLE award_types ADD CONSTRAINT award_types_metric_check
    CHECK (metric IS NULL OR metric IN ('attendance', 'appearances', 'keeper', 'newcomer'));
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  ALTER TABLE award_types ADD CONSTRAINT award_types_slots_check CHECK (slots BETWEEN 1 AND 11);
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

COMMENT ON COLUMN award_types.audience IS 'youth (boys/girls teams) · adult (mens/womens) · all (mig 1263)';
COMMENT ON COLUMN award_types.slots    IS 'Winners per team per season (mig 1263)';
COMMENT ON COLUMN award_types.metric   IS 'NULL = coach''s pick; else the stat fh_award_candidates ranks by (mig 1263)';

-- The existing three.
UPDATE award_types SET audience = 'youth', slots = 3,
       blurb = 'Picked by the coach, sent to the league director'
 WHERE code = 'all_star';
UPDATE award_types SET audience = 'all', sort_order = 20,
       blurb = 'Came furthest from the first week to the last'
 WHERE code = 'most_improved';
UPDATE award_types SET audience = 'all', metric = 'attendance', sort_order = 21,
       blurb = 'Showed up the most: practices and games'
 WHERE code = 'most_dedicated';

INSERT INTO award_types (code, label, emoji, is_league, sort_order, audience, slots, metric, blurb) VALUES
  -- Youth
  ('coaches_award',    'Coach''s Award',        '🧢', false, 10, 'youth', 1, NULL,          'The player the coach most wants the others to copy'),
  ('best_teammate',    'Best Teammate',         '🤝', false, 11, 'youth', 1, NULL,          'Encourages everyone, celebrates others'),
  ('hustle',           'Hustle Award',          '🔥', false, 12, 'youth', 1, NULL,          'Never stops running, first to every ball'),
  ('sportsmanship',    'Sportsmanship',         '🙌', false, 13, 'youth', 1, NULL,          'Respects refs, opponents and teammates'),
  -- Adults
  ('player_of_season', 'Player of the Season',  '🏆', false,  2, 'adult', 1, NULL,          'Best player on the team this season'),
  ('players_player',   'Players'' Player',      '🗳️', false,  3, 'adult', 1, NULL,          'The teammates'' pick'),
  ('golden_boot',      'Golden Boot',           '👟', false,  4, 'adult', 1, NULL,          'Most goals'),
  ('golden_glove',     'Golden Glove',          '🧤', false,  5, 'adult', 1, 'keeper',      'Best keeper'),
  ('defender',         'Defender of the Season','🛡️', false,  6, 'adult', 1, NULL,          'Best at the back'),
  ('iron_man',         'Iron Man',              '🦾', false,  7, 'adult', 1, 'appearances', 'Most games played'),
  ('newcomer',         'Newcomer of the Season','🌟', false,  8, 'adult', 1, 'newcomer',    'Best first season with the club'),
  ('clubman',          'Club Person of the Year','🏠', false, 9, 'adult', 1, NULL,          'Does the most for the club off the field')
ON CONFLICT (code) DO NOTHING;

-- Season window: the term's start to the next term's start.
CREATE OR REPLACE FUNCTION fh_term_window(p_term text, p_year int, OUT from_at timestamptz, OUT to_at timestamptz)
LANGUAGE sql STABLE AS $$
  WITH s AS (SELECT make_date(p_year, starts_month, starts_day) AS d0 FROM year_terms WHERE code = p_term)
  SELECT (s.d0::timestamp AT TIME ZONE 'America/New_York'),
         (SELECT min(CASE WHEN make_date(p_year, t.starts_month, t.starts_day) > s.d0
                          THEN make_date(p_year, t.starts_month, t.starts_day)
                          ELSE make_date(p_year + 1, t.starts_month, t.starts_day) END)
            FROM year_terms t WHERE t.code <> p_term)::timestamp AT TIME ZONE 'America/New_York'
    FROM s
$$;
COMMENT ON FUNCTION fh_term_window(text, int) IS 'A season''s window: its term start to the next term start, America/New_York (mig 1263).';

-- Suggested players per team per metric award.  Cheap filters first
-- (team + window + kind) before any per-person work.
CREATE OR REPLACE FUNCTION fh_award_candidates(p_term text, p_year int)
RETURNS TABLE (team_id int, award_code text, person_id int, rank int, value int, out_of int, basis text)
LANGUAGE sql STABLE AS $$
  WITH w AS (
    SELECT from_at, LEAST(to_at, now()) AS to_at FROM fh_term_window(p_term, p_year)
  ), tm AS (
    SELECT t.id, t.gender_category FROM teams t
     WHERE t.is_active AND t.board_sort_order IS NOT NULL
       AND (EXISTS (SELECT 1 FROM team_terms tt WHERE tt.team_id = t.id AND tt.term = p_term)
            OR NOT EXISTS (SELECT 1 FROM team_terms tt WHERE tt.team_id = t.id))
  ), ev AS MATERIALIZED (   -- the team's past practices + games in the window; marked = attendance taken
    SELECT et.team_id, e.id AS event_id, (e.kind = 'match') AS is_game,
           EXISTS (SELECT 1 FROM fh_event_attendance a WHERE a.fh_event_id = e.id) AS marked
      FROM tm
      JOIN fh_event_teams et ON et.team_id = tm.id
      JOIN fh_events e       ON e.id = et.fh_event_id AND e.kind IN ('practice', 'match')
      JOIN gcal_events g     ON g.id = e.gcal_event_id
      , w
     WHERE g.deleted_at IS NULL AND COALESCE(g.status, '') <> 'cancelled'
       AND g.starts_at >= w.from_at AND g.starts_at < w.to_at
  ), roster AS (
    SELECT DISTINCT tp.team_id, tp.person_id FROM team_persons tp JOIN tm ON tm.id = tp.team_id
     WHERE tp.removed_at IS NULL
  ), went AS (   -- one row per roster person per team event: went (attendance) or said yes (no attendance taken)
    SELECT r.team_id, r.person_id, ev.is_game, ev.marked,
           CASE WHEN ev.marked
                THEN EXISTS (SELECT 1 FROM fh_event_attendance a WHERE a.fh_event_id = ev.event_id
                               AND a.person_id = r.person_id AND a.status IN ('present', 'late'))
                ELSE EXISTS (SELECT 1 FROM fh_event_rsvps v WHERE v.fh_event_id = ev.event_id
                               AND v.person_id = r.person_id AND v.response = 'yes') END AS went
      FROM roster r JOIN ev ON ev.team_id = r.team_id
  ), per AS (
    SELECT r.team_id, r.person_id,
           count(*) FILTER (WHERE g.went AND g.is_game)::int AS games,
           count(g.is_game) FILTER (WHERE g.is_game)::int    AS games_of,
           count(*) FILTER (WHERE g.went)::int               AS events,
           count(g.is_game)::int                             AS events_of,
           bool_and(g.marked) FILTER (WHERE g.is_game)       AS games_marked,
           bool_or(g.marked)  FILTER (WHERE g.is_game)       AS games_some,
           bool_and(g.marked)                                AS all_marked,
           bool_or(g.marked)                                 AS some_marked
      FROM roster r LEFT JOIN went g ON g.team_id = r.team_id AND g.person_id = r.person_id
     GROUP BY r.team_id, r.person_id
  ), scored AS (
    SELECT p.team_id, a.code AS award_code, p.person_id,
           CASE WHEN a.metric IN ('appearances', 'keeper') THEN p.games    ELSE p.events    END AS value,
           CASE WHEN a.metric IN ('appearances', 'keeper') THEN p.games_of ELSE p.events_of END AS out_of,
           CASE WHEN a.metric IN ('appearances', 'keeper')
                THEN CASE WHEN p.games_marked THEN 'attendance' WHEN p.games_some THEN 'mixed' ELSE 'rsvp' END
                ELSE CASE WHEN p.all_marked   THEN 'attendance' WHEN p.some_marked THEN 'mixed' ELSE 'rsvp' END END AS basis
      FROM per p
      JOIN tm ON tm.id = p.team_id
      JOIN award_types a ON a.is_active AND a.metric IS NOT NULL
       AND (a.audience = 'all'
            OR (a.audience = 'youth' AND tm.gender_category IN ('boys', 'girls'))
            OR (a.audience = 'adult' AND tm.gender_category IN ('mens', 'womens')))
     WHERE (a.metric <> 'keeper' OR EXISTS (SELECT 1 FROM players pl WHERE pl.person_id = p.person_id
                                               AND (pl.is_keeper OR EXISTS (
                                                 SELECT 1 FROM match_lineups l JOIN positions pos ON pos.id = l.position_id
                                                  WHERE l.player_id = pl.id AND l.is_starter AND pos.abbreviation = 'GK'
                                                    AND l.fh_event_id IN (SELECT event_id FROM ev WHERE ev.team_id = p.team_id)))))
       -- Newcomer: first seen with the club this season — earliest real team join (1970 = imported placeholder) or first RSVP.
       AND (a.metric <> 'newcomer' OR (SELECT from_at FROM w) <= LEAST(
             (SELECT min(x.joined_at) FROM team_persons x WHERE x.person_id = p.person_id AND x.joined_at > '1971-01-01'),
             (SELECT min(g.starts_at) FROM fh_event_rsvps v JOIN fh_events e ON e.id = v.fh_event_id
                JOIN gcal_events g ON g.id = e.gcal_event_id WHERE v.person_id = p.person_id)))
  )
  SELECT team_id, award_code, person_id,
         (rank() OVER (PARTITION BY team_id, award_code ORDER BY value DESC))::int AS rank,
         value, out_of, basis
    FROM scored
   WHERE value > 0
$$;
COMMENT ON FUNCTION fh_award_candidates(text, int) IS
  '#awards suggestions: per team per metric award, players ranked by attendance (or yes-RSVPs where nobody marked attendance) in the season window (mig 1263).';

-- Copy (kind = awards).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Awards', l, 'awards', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('sub2',          'Page subtitle (slots)',                    'Each award has slots per team — 💡 = suggested from attendance, tap to give it', 1308),
    ('suggested',     'Suggested chip ({name} {stat})',           '💡 {name} · {stat}', 1309),
    ('stat_attend',   'Stat — attendance ({n} {of})',             '{n} of {of} attended', 1310),
    ('stat_rsvp',     'Stat — RSVP fallback ({n} {of})',          '{n} of {of} said yes', 1311),
    ('stat_mixed',    'Stat — attendance, or a yes RSVP where none was taken ({n} {of})', '{n} of {of} went', 1317),
    ('fill',          'Fill suggested button',                    '💡 Give every clear suggestion', 1318),
    ('tie',           'Tie note ({n})',                           'tied — {n} players', 1319),
    ('pick',          'Empty slot — pick a player',               '＋ pick', 1312),
    ('coach_pick',    'No data — coach''s pick',                  'coach''s pick', 1313),
    ('youth_heading', 'Youth awards heading',                     'Youth awards', 1314),
    ('adult_heading', 'Adult awards heading',                     'Adult awards', 1315),
    ('filled',        'Team card count ({filled} {slots})',       '{filled} of {slots} slots filled', 1316)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'awards' AND m.tier = v.t);
