-- 586 (2026-10-14) — teams.rsvp_board: put a team's games on the #rsvps
-- board WITHOUT giving it a #teams column.
--
-- The cup pool (mig 585) made the USASA Cup game roster-driven, but the
-- RSVP board, per-player reminders and roll call all scope teams by
-- `board_sort_order IS NOT NULL` — the same switch that creates a #teams
-- column, a move-dropdown target and a public listing.  The cup container
-- team must stay off all of those (mig 567), so it gets this explicit
-- flag instead and RsvpBoard.cpp now takes
-- (board_sort_order IS NOT NULL OR rsvp_board).
-- Owner: "treat it like an apsl game for rsvp eligibility … important to
-- not have a guy on cup pool that is unavailable this sunday."

ALTER TABLE teams ADD COLUMN IF NOT EXISTS rsvp_board boolean NOT NULL DEFAULT false;
COMMENT ON COLUMN teams.rsvp_board IS
  'RSVP-board membership without a #teams column: the board/reminder/roll-call team scope is (board_sort_order IS NOT NULL OR rsvp_board). For container teams like USASA Cup (mig 586).';

UPDATE teams SET rsvp_board = true
 WHERE club_id = 134 AND name = 'USASA Cup' AND NOT rsvp_board;
