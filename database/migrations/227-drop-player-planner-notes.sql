-- Migration 227: drop Summer Planner notes table
--
-- The Summer Planner / internal roster board was removed from the
-- frontend and backend.  Its player_planner_notes table only stored
-- planner-local position notes, so existing databases should drop it.

BEGIN;

DROP TABLE IF EXISTS player_planner_notes;

COMMIT;