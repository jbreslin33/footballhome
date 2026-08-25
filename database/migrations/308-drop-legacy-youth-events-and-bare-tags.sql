-- 308 — Retire the superseded youth calendar series and the bare age tags.
--
-- Why (2026-08-25, owner: "i made the events recurring for each day not
-- muliple mon, wed per week. so we can delete the others for youth. use
-- the new ones. youth has not used rsvp system yet so not a problem. men
-- is fine don't mess with it." — following "lets get rid of the also
-- accepted it will get confusing. lets lock in actual vars").
--
-- Ops rebuilt the youth calendar as one recurring series per weekday
-- instead of one series covering several weekdays, and retagged them with
-- the full Travel/Intramural team names. The new series are live and
-- resolving: three Grades 3-10 series and two K-2, 730 instances each,
-- every one of the nine boys teams attached (1,459 future events for the
-- K-2 ages, 2,189 for the older band).
--
-- What is left behind are 14 stray instances of the two OLD series, all
-- in the past, still carrying the bare tags `Team: u6, u8` and
-- `Team: u10, u12, u19`. They hold 7 RSVPs and 2 attendance rows — all of
-- them James Breslin, Luke Breslin or Anthony Acevedo, 2026-08-14 to
-- 08-18, every one a 'yes' on a practice that has already happened. That
-- is the testing the owner meant by "not a problem"; cascading it away
-- costs nothing anyone will look for.
--
-- Deleting them is what finally frees the five bare aliases. Until now
-- 'u6'/'u8'/'u10'/'u12'/'u19' had to stay because these events pointed at
-- them (migration 307 kept them deliberately for exactly this reason).
-- With the events gone, one spelling per team is real — the team's own name,
-- lowercased, and nothing else.
--
-- Mens is untouched throughout, per the owner. Its events already tag
-- 'apsl' and 'liga 1', which are canonical, and none of the aliases
-- removed here belong to a mens team.

BEGIN;

-- ── The superseded series ─────────────────────────────────────────────
-- fh_event_rsvps / _attendance / _teams and player_event_reminders all
-- cascade from fh_events; fh_events itself is RESTRICT on gcal_events, so
-- it must go first and explicitly.
CREATE TEMP TABLE dead_series (recurring_event_id TEXT PRIMARY KEY);
INSERT INTO dead_series VALUES
    ('eeq9lm1lf61ctp5epuaabk40e2'),                  -- old Soccer Practice Grades 3-10
    ('eeq9lm1lf61ctp5epuaabk40e2_R20260817T213000'), -- …its split-off instance series
    ('40vq0a4cqb1jmd8lkb58h5oe21_R20260817T203000'); -- old Soccer Practice Kindergarten-2nd

-- Guard: never delete a FUTURE event this way. If ops has since pointed a
-- live series at one of these ids, stop rather than silently cancel
-- practices people are expecting.
DO $$
DECLARE n INT;
BEGIN
    SELECT count(*) INTO n
      FROM gcal_events ge JOIN dead_series d USING (recurring_event_id)
     WHERE ge.deleted_at IS NULL AND ge.starts_at > now();
    IF n > 0 THEN
        RAISE EXCEPTION 'refusing to delete % future event(s) from the legacy youth series', n;
    END IF;
END $$;

DELETE FROM fh_events
 WHERE gcal_event_id IN (SELECT id FROM gcal_events
                          WHERE recurring_event_id IN (SELECT recurring_event_id FROM dead_series));

DELETE FROM gcal_events
 WHERE recurring_event_id IN (SELECT recurring_event_id FROM dead_series);

-- ── The bare age tags ─────────────────────────────────────────────────
-- 'u8'/'u10'/'u12' resolved to the TRAVEL squad alone and silently
-- excluded the house team — the specific confusion the owner asked to
-- remove. 'u6'/'u19' were unambiguous but go too: one spelling per team,
-- no exceptions to remember.
DELETE FROM gcal_team_aliases
 WHERE club_alias = 'boys'
   AND team_alias IN ('u6', 'u8', 'u10', 'u12', 'u19');

-- Guard: after this, every surviving boys alias must be a team's own
-- lowercased name, and every boys team must have exactly one.
DO $$
DECLARE bad TEXT;
BEGIN
    SELECT string_agg(msg, '; ') INTO bad FROM (
        SELECT 'alias ' || g.team_alias || ' <> name of ' || t.name AS msg
          FROM gcal_team_aliases g JOIN teams t ON t.id = g.team_id
         WHERE g.club_alias = 'boys' AND g.team_alias <> lower(t.name)
        UNION ALL
        SELECT 'team ' || t.name || ' has ' || count(g.*) || ' aliases'
          FROM teams t LEFT JOIN gcal_team_aliases g
            ON g.team_id = t.id AND g.club_alias = 'boys'
         WHERE t.gender_category = 'boys' AND t.is_active
         GROUP BY t.name HAVING count(g.*) <> 1
    ) x;
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'boys alias set is not one-name-per-team: %', bad;
    END IF;
END $$;

COMMIT;
