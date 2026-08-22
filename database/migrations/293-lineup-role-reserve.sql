-- 293 — Adds a third lineup_roles value, 'reserve', so a Liga 1 player can
-- be marked as the club's APSL reserve/call-up pool alongside the existing
-- starter/bench designations (migration 283).
--
-- 2026-08-22 (owner directive): the UI's old two-button "Elig: Start" /
-- "Elig: Bench" toggle (game-lineup.js) is replaced with a single "Roster
-- Role" dropdown — APSL Starter / APSL Bench / APSL Reserve — and moves
-- from the per-match lineup screen onto the Teams roster board
-- (mens-roster.js), where a player's standing team_persons designation
-- actually belongs.

BEGIN;

INSERT INTO lineup_roles (id, name, description, sort_order) VALUES
    (3, 'reserve', 'Liga 1 player held as APSL reserve / call-up pool', 3);

COMMIT;
