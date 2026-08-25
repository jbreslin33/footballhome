-- 309 — Delete the "Practice" team (908).
--
-- Why (2026-08-25, owner: "so i don't think we need a practice 'team'
-- now. there is no practice membership either. we list a practice in
-- gcal and we assign teams to the practice right?" → "yes clean it all
-- up").
--
-- Correct, and the calendar already works that way. A practice is two
-- independent tags: `Type: Practice` says what KIND of event it is, and
-- `Team:` says who is invited. All 3,648 future practices carry both, and
-- not one of them tags team 908.
--
-- 908 is a fossil of the retired pool model. LaPool.cpp says as much:
-- "Practice (908) + Pickup (909) are now UNION teams … Going forward,
-- practice/pickup eligibility comes from tagging the REAL teams on the
-- gcal event." Migration 107 retired the union machinery in 2026-07-07;
-- the team row was left behind and has been accumulating members ever
-- since, from an auto-add on every APSL / Liga 1 assignment.
--
-- Unlike Pickup (909) there is nothing behind it: no LA program, no
-- registration, no variant='practice' row in leagueapps_programs. It is
-- the one team in the database that mirrors nothing, which is why it
-- could drift without anyone noticing — there was no truth to drift from.
--
-- What goes with it: 101 team_persons rows (67 still open) and 60
-- player_rsvp_eligibility rows, all by cascade. Those 67 are inert —
-- eligibility comes from the event tags now — and closing them returns
-- those people to Unassigned, which is where someone on no active team
-- belongs (migration 302's rule).
--
-- Three matches list 908 as home team: 9223, 9225, 9227, all early July
-- 2026, no lineups and no match events. They are empty shells created
-- against the pool team, and matches.home_team_id is NO ACTION, so they
-- must go first or the delete is refused.
--
-- So do three match_series rows — the recurring generators from the same
-- retired pool model: 2 "Wednesday Practice", 4 "Friday Practice", and 6
-- "TEST Sunday Scrimmage" (its own description says "api-created test
-- row"). All three are active=false and between them generated the two
-- past matches above and nothing since. matches.series_id is SET NULL, so
-- no surviving match loses a row by their going.
--
-- The other three series — 1/3/5, the Pickup generators — are left alone.
-- They are equally dead (active=false, zero matches ever), but they point
-- at team 909, which stays, so they are not this migration's business.
-- Worth a look separately.
--
-- Pickup (909) STAYS. It mirrors a real paid LA registration (program
-- 5070075), LaPool writes it in both directions as of migration 304/305,
-- and CalendarController still needs it to tell a pickup-only member from
-- a squad player.

BEGIN;

-- Guard: never do this while a scheduled event still expects the team.
DO $$
DECLARE n INT;
BEGIN
    SELECT count(*) INTO n
      FROM fh_event_teams fet
      JOIN fh_events fe    ON fe.id = fet.fh_event_id
      JOIN gcal_events ge  ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL
     WHERE fet.team_id = 908 AND ge.starts_at > now();
    IF n > 0 THEN
        RAISE EXCEPTION 'refusing to delete Practice: % future event(s) still tag it', n;
    END IF;
END $$;

-- Guard: the three matches must still be the empty shells described above.
DO $$
DECLARE n INT;
BEGIN
    SELECT count(*) INTO n FROM matches m
     WHERE (m.home_team_id = 908 OR m.away_team_id = 908)
       AND (EXISTS (SELECT 1 FROM match_lineups ml WHERE ml.match_id = m.id)
         OR EXISTS (SELECT 1 FROM match_events  me WHERE me.match_id = m.id));
    IF n > 0 THEN
        RAISE EXCEPTION 'refusing to delete Practice: % match(es) carry lineups or events', n;
    END IF;
END $$;

-- Guard: the series must still be inactive with nothing scheduled ahead.
DO $$
DECLARE n INT;
BEGIN
    SELECT count(*) INTO n FROM match_series ms
     WHERE (ms.home_team_id = 908 OR ms.away_team_id = 908)
       AND (ms.active
         OR EXISTS (SELECT 1 FROM matches m
                     WHERE m.series_id = ms.id AND m.match_date > current_date));
    IF n > 0 THEN
        RAISE EXCEPTION 'refusing to delete Practice: % series active or still generating', n;
    END IF;
END $$;

DELETE FROM matches           WHERE home_team_id = 908 OR away_team_id = 908;
DELETE FROM match_series      WHERE home_team_id = 908 OR away_team_id = 908;
DELETE FROM fh_event_teams    WHERE team_id = 908;
DELETE FROM gcal_team_aliases WHERE team_id = 908;
DELETE FROM teams             WHERE id = 908;

COMMIT;
