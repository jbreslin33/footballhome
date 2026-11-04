-- 1058: PPR Indoor is 5v5 — 4 outfield + keeper — with a 12-player roster
-- (owner 2026-11-04: "so max roster is 12 and games are 5v5(4v4 +
-- keeper)").  Winter U10 (942), U11 (946), U12 (940): field_size 5 (Game
-- Center's 1-2-1 pitch, the board's "5v5 · N subs"), matchday squad 12
-- (NULL would be field + 9 = 14, more than the roster), max roster 12
-- (mig 1055; U11 since mig 1056).

UPDATE teams SET field_size = 5, matchday_squad_size = 12, max_roster = 12
 WHERE id IN (940, 942, 946);
