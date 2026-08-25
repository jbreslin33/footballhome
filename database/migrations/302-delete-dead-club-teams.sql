-- 302 — Delete the club's retired teams outright.
--
-- Why (2026-08-25, owner: "lets delete all teams that are not live. it is
-- causing problems … don't care about events as it was from a time we
-- didn't care … end of the day you need to make sure a member shows in
-- unassigned if they are not on an active team").
--
-- is_active=false was being used as "retired", but a retired team is not
-- inert: it still holds team_persons rows, and BoysRoster/MensRoster skip
-- a player from Unassigned when their only assignments are to off-view
-- teams. So a retired team quietly swallows players — six of them on U19
-- (migration 300) — and its gcal_team_aliases keep intercepting calendar
-- tags, which is how `Team: u8` and `Team: u12` have been attaching the
-- empty "Lighthouse Youth League" rosters instead of the real U8 and U12.
-- Deleting the rows removes both failure modes at the source: no row, no
-- assignment to hide behind, no alias to intercept.
--
-- ── What is NOT deleted ───────────────────────────────────────────────
-- Every is_active=false team owned by the club EXCEPT Practice (908) and
-- Pickup (909). Those two are is_active=false only in the sense of being
-- archived off the board — they are live in the code:
--   * LaPool.cpp writes direct rows on 909 for every LA pickup member
--     (program 5070075), so deleting it breaks the sync with an FK error.
--   * CalendarController.cpp's RSVP eligibility query names them
--     explicitly (`AND tp_sel.team_id NOT IN (908, 909)`).
--   * Together they hold 149 live memberships and 121 rsvp-eligibility
--     rows — the men's practice and pickup RSVP structure.
-- They are exactly the "except for LIVE" carve-out. Retiring them is a
-- code change, not a delete, and is not attempted here.
--
-- No opponent team is touched. Every one of the club's 94 opponent rows
-- (Real Central and the rest) is is_active=true with a NULL
-- gender_category, so the rule below cannot reach them; the list is
-- spelled out by id regardless.
--
-- ── What goes with them ───────────────────────────────────────────────
-- Cascading FKs carry away 392 team_persons rows (34 of them still open,
-- across 33 people), 221 rosters, 121 working_rosters, 59
-- player_rsvp_eligibility, 20 team_membership_requirements and 12
-- team_coaches. The 34 open rows are the point, not collateral: closing
-- them is what returns those 33 people to Unassigned.
--
-- Three FKs are NO ACTION and must be cleared by hand first. 7,285
-- fh_event_teams rows are the "events from a time we didn't care" the
-- owner waved off — the events themselves survive, only their attachment
-- to a dead roster goes. A full pre-cleanup pg_dump was taken first.

BEGIN;

CREATE TEMP TABLE dead_teams (id INTEGER PRIMARY KEY);
INSERT INTO dead_teams (id) VALUES
    -- boys
    (910),  -- Dues Owed (Admin)
    (911),  -- Lighthouse Youth League U16
    (916),  -- Lighthouse Youth League U8   — intercepts `Team: u8`
    (917),  -- Lighthouse Youth League U12  — intercepts `Team: u12`
    (927), (928), (929),          -- U8 / U10 / U12 Boys Trialists
    -- mens
    (121),  -- Lighthouse Boys Club Liga 2
    (122),  -- Lighthouse Adult League
    (903),  -- U23 Men            (32 open memberships)
    (904),  -- Dominican Republic
    (905),  -- Puerto Rico        (2 open memberships)
    (924),  -- APSL Reserves
    (925),  -- APSL Trialists
    (926),  -- Liga 1 Trialists
    -- no gender_category
    (461),  -- Lighthouse Boys Club U23 Liga 1
    (583),  -- Lighthouse Women's Club
    (902);  -- U23 Women

-- Guard: refuse to run if this list ever picks up a live team or another
-- club's. Cheaper than discovering it from a restore.
DO $$
DECLARE bad TEXT;
BEGIN
    SELECT string_agg(t.id || ' ' || t.name, ', ')
      INTO bad
      FROM teams t JOIN dead_teams d ON d.id = t.id
     WHERE t.is_active OR t.id IN (908, 909)
        OR (t.club_id IS NOT NULL AND t.club_id <> 134);
    IF bad IS NOT NULL THEN
        RAISE EXCEPTION 'refusing to delete live or third-party teams: %', bad;
    END IF;
END $$;

-- ── NO ACTION FKs, cleared so the delete can proceed ──────────────────
DELETE FROM fh_event_teams    WHERE team_id IN (SELECT id FROM dead_teams);
DELETE FROM gcal_team_aliases WHERE team_id IN (SELECT id FROM dead_teams);
-- One chat, "Lighthouse Boys Club U23" on team 121: zero messages, three
-- chat_events, all cascading. Dead alongside its team.
DELETE FROM chats             WHERE team_id IN (SELECT id FROM dead_teams);

DELETE FROM teams WHERE id IN (SELECT id FROM dead_teams);

COMMIT;
