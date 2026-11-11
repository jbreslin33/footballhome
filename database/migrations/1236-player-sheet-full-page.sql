-- 1236 (2026-11-11) — #person is the player sheet, full page.
--
-- Owner 2026-11-11: the ⋯ sheet "could also replace going into the player
-- screen".  #person now draws the same seven tabs in the same order as the
-- ⋯ popup (PlayerSheet.page); its old cards ride in their tab — header /
-- account / LA memberships / data quality → 👤 Person, contact → 📇 Contact,
-- team assignments → ⚽ Teams, billing → 💳 Money, event access + recent
-- RSVPs → 📅 Activity.  The popup gets ⤢ = open this player full page on
-- the same tab.  Words below: kind player_sheet (mig 1235).

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Player sheet', v.label, 'player_sheet', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('full_page', 'Player sheet — ⤢ open full page tooltip', 'Open as a full page', 3)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'player_sheet' AND t.tier = v.tier);
