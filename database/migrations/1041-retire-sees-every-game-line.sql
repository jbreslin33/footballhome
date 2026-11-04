-- 1041: the Team pill's "👀 Sees every game: N / 20" line is gone (owner
-- 2026-11-04: "👀 Sees every game: 36 / 20 stil there lol").  Each card's
-- 👀⚽ chip (mig 1040) says who sees the column's games.  Copy rows off.

UPDATE message_templates SET is_active = false
 WHERE kind = 'roster_sheet' AND tier IN ('board_sees_ok', 'board_sees_short');
