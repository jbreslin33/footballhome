-- 456 — Starter eligibility window (owner 2026-09-26, the men's group
-- message): "Players need 2 practices leading into game to start.  But for
-- weekday game weeks we have to adjust.  We count the last 5 the week
-- before and all DAYS LEADING up to weekday game AND all days leading up to
-- the next weekend game."  Then: "this will be policy if you detect a game
-- on a weekday, otherwise count last 5 practices leading to a game."
--
-- eligibility_policies (system default → club → team → match) already held
-- lookback_count = 5 and min_sessions_to_start = 2 but nothing read it; the
-- Game Center computed a fixed 6-day window in C++.  From here on the
-- window is fh_starter_window():
--
--   normal game        the last `lookback_count` sessions before kickoff
--   weekday game       the last `lookback_count` sessions on or before the
--                      week cutoff (Saturday) before the game, PLUS every
--                      session after that cutoff up to kickoff
--   weekend game that  the same cutoff as that weekday game, so the window
--   follows a weekday  runs from the week before straight through to the
--   game (≤ 7 days)    weekend game
--
-- Worked example, APSL Wed 9/30 + Sun 10/4: cutoff = Sat 9/26.  Last 5 on
-- or before it = Sat 9/19, Tue, Wed, Thu, Fri 9/25.  Wed game adds Sun
-- 9/27, Mon, Tue.  Sunday game adds Sun, Mon, Tue, Fri, Sat.
--
-- A session = practice / barn night, plus pickup and games when the policy
-- flags say so.  The default row's game_counts_as_session flips to false:
-- the owner's example counts Sun/Mon/Tue/Fri/Sat for the Sunday game and
-- not the Wednesday match, and the C++ never counted matches either.

ALTER TABLE eligibility_policies
  ADD COLUMN IF NOT EXISTS weekday_game_extends_window BOOLEAN NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS week_cutoff_dow INT NOT NULL DEFAULT 6 CHECK (week_cutoff_dow BETWEEN 0 AND 6);

COMMENT ON COLUMN eligibility_policies.weekday_game_extends_window IS
  'mig 456: a Mon–Fri game (and the weekend game right after it) counts the last lookback_count sessions before the week cutoff plus everything since.';
COMMENT ON COLUMN eligibility_policies.week_cutoff_dow IS
  'mig 456: day of week (0=Sunday … 6=Saturday, America/New_York) that ends "the week before" for the extended window.';
COMMENT ON TABLE eligibility_policies IS
  'Starter eligibility rules, cascading system default → club → team → match (most specific wins). Read by fh_starter_policy() / fh_starter_window() (mig 456).';

UPDATE eligibility_policies
   SET game_counts_as_session = false,
       notes = 'System default (mig 456): 2 of the last 5 sessions to start; a weekday game extends the window (see fh_starter_window). Games do not count as sessions.'
 WHERE club_id IS NULL AND team_id IS NULL AND match_id IS NULL;

-- Most specific policy for a set of teams (a shared-squad game carries
-- several) and an optional match.
CREATE OR REPLACE FUNCTION fh_starter_policy(p_team_ids INT[], p_match_id INT)
RETURNS eligibility_policies LANGUAGE sql STABLE AS $$
  SELECT p.* FROM eligibility_policies p
   WHERE (p_match_id IS NOT NULL AND p.match_id = p_match_id)
      OR (p.match_id IS NULL AND p.team_id = ANY(p_team_ids))
      OR (p.match_id IS NULL AND p.team_id IS NULL
          AND p.club_id IN (SELECT t.club_id FROM teams t WHERE t.id = ANY(p_team_ids)))
      OR (p.match_id IS NULL AND p.team_id IS NULL AND p.club_id IS NULL)
   ORDER BY (p.match_id IS NOT NULL) DESC, (p.team_id IS NOT NULL) DESC, (p.club_id IS NOT NULL) DESC, p.id
   LIMIT 1;
$$;

-- Start of the day after the last `p_cutoff_dow` day strictly before the
-- game's local date: "on or before Saturday" is starts_at < this value.
CREATE OR REPLACE FUNCTION fh_week_cutoff(p_kickoff TIMESTAMPTZ, p_cutoff_dow INT)
RETURNS TIMESTAMPTZ LANGUAGE sql IMMUTABLE AS $$
  WITH d AS (SELECT (p_kickoff AT TIME ZONE 'America/New_York')::date AS game_date)
  SELECT ((game_date - (((EXTRACT(DOW FROM game_date)::int - p_cutoff_dow + 7) % 7)
                        + CASE WHEN ((EXTRACT(DOW FROM game_date)::int - p_cutoff_dow + 7) % 7) = 0 THEN 7 ELSE 0 END)
           + 1)::timestamp AT TIME ZONE 'America/New_York')
    FROM d;
$$;

-- The sessions that decide whether a player may start a game.
--   fh_event_id / kind / starts_at   one row per counted session, ascending
--   extended                         true when the weekday rule applied
--   cutoff                           the week cutoff used (NULL when not)
DROP FUNCTION IF EXISTS fh_starter_window(INT[], TIMESTAMPTZ, INT);
CREATE FUNCTION fh_starter_window(p_team_ids INT[], p_kickoff TIMESTAMPTZ, p_match_id INT)
RETURNS TABLE (fh_event_id BIGINT, kind TEXT, starts_at TIMESTAMPTZ, extended BOOLEAN, cutoff TIMESTAMPTZ)
LANGUAGE plpgsql STABLE AS $$
DECLARE
  pol      eligibility_policies;
  v_dow    INT;
  v_cutoff TIMESTAMPTZ := NULL;
  v_wk     TIMESTAMPTZ;
BEGIN
  pol := fh_starter_policy(p_team_ids, p_match_id);
  IF pol.id IS NULL THEN
    pol.lookback_count := 5; pol.pickup_counts_as_session := true; pol.game_counts_as_session := false;
    pol.weekday_game_extends_window := true; pol.week_cutoff_dow := 6;
  END IF;

  IF pol.weekday_game_extends_window THEN
    v_dow := EXTRACT(DOW FROM p_kickoff AT TIME ZONE 'America/New_York')::int;
    IF v_dow BETWEEN 1 AND 5 THEN
      v_cutoff := fh_week_cutoff(p_kickoff, pol.week_cutoff_dow);
    ELSE
      -- Weekend game: the most recent weekday game for these teams within
      -- the past 7 days lends its cutoff.
      SELECT ge.starts_at INTO v_wk
        FROM fh_events fe
        JOIN gcal_events ge ON ge.id = fe.gcal_event_id
       WHERE fe.kind = 'match' AND ge.deleted_at IS NULL
         AND ge.starts_at > p_kickoff - INTERVAL '7 days' AND ge.starts_at < p_kickoff
         AND EXTRACT(DOW FROM ge.starts_at AT TIME ZONE 'America/New_York')::int BETWEEN 1 AND 5
         AND EXISTS (SELECT 1 FROM fh_event_teams fet WHERE fet.fh_event_id = fe.id AND fet.team_id = ANY(p_team_ids))
       ORDER BY ge.starts_at DESC LIMIT 1;
      IF v_wk IS NOT NULL THEN v_cutoff := fh_week_cutoff(v_wk, pol.week_cutoff_dow); END IF;
    END IF;
  END IF;

  RETURN QUERY
  WITH sessions AS (
    SELECT DISTINCT fe.id AS fh_event_id, fe.kind::text AS kind, ge.starts_at
      FROM fh_events fe
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id
      JOIN fh_event_teams fet ON fet.fh_event_id = fe.id
     WHERE fet.team_id = ANY(p_team_ids)
       AND ge.deleted_at IS NULL
       AND ge.starts_at < p_kickoff
       AND (fe.kind IN ('practice', 'barn night')
            OR (fe.kind = 'pickup' AND pol.pickup_counts_as_session)
            OR (fe.kind = 'match'  AND pol.game_counts_as_session))
  ),
  picked AS (
    SELECT s.* FROM (
      SELECT s.* FROM sessions s
       WHERE v_cutoff IS NULL OR s.starts_at < v_cutoff
       ORDER BY s.starts_at DESC
       LIMIT pol.lookback_count
    ) s
    UNION
    SELECT s.* FROM sessions s WHERE v_cutoff IS NOT NULL AND s.starts_at >= v_cutoff
  )
  SELECT p.fh_event_id, p.kind, p.starts_at, (v_cutoff IS NOT NULL), v_cutoff
    FROM picked p ORDER BY p.starts_at;
END;
$$;

COMMENT ON FUNCTION fh_starter_window(INT[], TIMESTAMPTZ, INT) IS
  'Sessions counted for starter eligibility at a game (mig 456): last lookback_count before kickoff, or the weekday-game extended window.';

-- Player-facing copy (client_side, MessageCopy.block('eligibility', tier)).
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('eligibility', 'pill_eligible',  'Game Center — starter pill (eligible)',
  '✅ Eligible to start — {attended} of {needed} practices made', 1);
SELECT pg_temp.add_client_tpl('eligibility', 'pill_on_track',  'Game Center — starter pill (short, but going to enough)',
  '📅 On track — {attended} made, going to {projected} more', 2);
SELECT pg_temp.add_client_tpl('eligibility', 'pill_short',     'Game Center — starter pill (short)',
  '⏳ {remaining} more practice{plural} to start — {attended} of {needed} made', 3);
SELECT pg_temp.add_client_tpl('eligibility', 'pill_missed',    'Game Center — starter pill (no sessions left)',
  '❌ Not eligible to start — {attended} of {needed} practices made', 4);
SELECT pg_temp.add_client_tpl('eligibility', 'rule',           'Game Center — starter rule explainer',
  'You need {needed} of the last {lookback} practices to start. Attendance is taken at every practice; a Going RSVP shows as projected, but you have to be marked present for it to count.', 5);
SELECT pg_temp.add_client_tpl('eligibility', 'rule_extended',  'Game Center — starter rule explainer (weekday game)',
  'This game is on or right after a weekday game, so the window is wider: the last {lookback} practices before {cutoff} plus every practice since. You still need {needed}.', 6);
SELECT pg_temp.add_client_tpl('eligibility', 'remedy_heading', 'Game Center — practices still available heading',
  'Practices you can still make', 7);
SELECT pg_temp.add_client_tpl('eligibility', 'remedy_none',    'Game Center — no practices left',
  'No practices left before this game.', 8);
SELECT pg_temp.add_client_tpl('eligibility', 'window_heading', 'Game Center — counted practices heading',
  'Practices that count for this game', 9);

-- "Lineup" → "Game Center" in what players read (owner 2026-09-26: "the
-- lineup for players should be called game center for them too").
UPDATE message_templates
   SET body = replace(body, 'See the lineup or change your availability', 'See the Game Center or change your availability')
 WHERE kind = 'squad_notice' AND body LIKE '%See the lineup or change your availability%';
