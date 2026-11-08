-- 1184 (2026-11-07) — A posted weekend slideshow says why its games are
-- locked, and how to unlock them.  Owner: "it don't let me click the older
-- games … or unclick either lol" — the week's Game Announcements was already
-- posted, which locks the list, but the only way out sat at the bottom as
-- "I deleted it from Instagram".  Now the top of the panel says it's posted,
-- ticks show the games that went out, and one button unlocks the week for a
-- new slideshow (POST /api/social/carousels/:id/reopen).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', v.label, 'weekend_slides', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('locked',         'Weekend slideshow — posted, list locked',
     '✅ Posted {when} with the games ticked below, so the list is locked.', 24),
    ('unlock_button',  'Weekend slideshow — unlock button',
     '🔓 Make a new slideshow for this week', 25),
    ('unlock_confirm', 'Weekend slideshow — unlock, second tap',
     'Tap again to unlock (delete the old one in Instagram if this replaces it)', 26)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'weekend_slides' AND m.tier = v.tier);
