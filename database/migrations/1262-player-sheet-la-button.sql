-- 1262 (2026-11-11) — 🔗 Open in LA on the player sheet's Money AND Fines tabs.
--
-- Owner 2026-11-11: the ⋯ sheet's Fines pill "needs a button to access la
-- right like in tuitions".  The button is now part of the sheet itself
-- (PlayerSheet core), so 💳 Money and ⚖️ Fines carry it on every screen
-- that opens the sheet (#payments, #fines, #person, …); #payments' own copy
-- on Money was dropped.  Words: kind player_sheet (mig 1235).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Player sheet', v.label, 'player_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('la_button', 'Player sheet — Open in LA button (Money + Fines tabs)', '🔗 Open in LA', 4),
    ('la_title',  'Player sheet — Open in LA tooltip', 'Open in LeagueApps — run card, see tuition and fines charges', 5)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'player_sheet' AND t.tier = v.tier);
