-- 1048: winter U12 (940) ACTIVE — eleven kids (owner 2026-11-04: "add the
-- following to u12 winter 'ACTIVE': cotto, damaj, joseph bradham, grace
-- breslin, ezra, idris, jhon, kamryn, brandon velez", then "also add ryan
-- terrero", "also add Ahleem smith").  Winter has no league
-- list, so the youth rule (mig 1031/1033) keeps everyone 🏋 Practice Squad;
-- On Roster on this team (set by hand — no online list) gives a full spot
-- that the rule keeps: Roster pill ON ROSTER, Team pill ACTIVE, U12 winter
-- games.  Ilia Armstrong Cotto 22554, Damaj Austin 22484, Joseph Bradham
-- 22413, Grace Breslin 22364, Ezra Caraballo 22344, Muhammad Idris 22711,
-- Jhon Sagbaicela 22745, Kamryn Smith 22426, Brandon Velez 22574, Ryan
-- Terrero 22349, Ahleem Smith 22596.

UPDATE team_persons SET roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'on_roster')
 WHERE team_id = 940 AND removed_at IS NULL
   AND person_id IN (22554, 22484, 22413, 22364, 22344, 22711, 22745, 22426, 22574, 22349, 22596);
