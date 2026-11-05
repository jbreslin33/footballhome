-- 1088: every player card's dues pill (💰 Paid up / Owes $X / No
-- membership on Event Center + Game Center, "Dues" on #teams) opens his
-- LeagueApps Manager member page in a new tab — owner 2026-11-05: "i
-- should be able to run card from la from event center for a player who
-- owes dues. and really from anyone … universal on all player cards".
-- Built in PersonStanding.laLink; /api/payments/standing now sends laUserId.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Person standing', 'Dues pill tooltip — opens LeagueApps', 'person_standing', 'dues_la_tip', NULL,
       'Open in LeagueApps — run card, see tuition', 40, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'person_standing' AND tier = 'dues_la_tip');
