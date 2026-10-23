-- 664 (2026-10-23) — Standing call-downs sit with the squad in Game Center.
-- Owner: "sheldon and pena should not be in call ups. they first off are
-- call downs. 2nd they need to be by default with the normal list of
-- players just have a label on them. if not i will miss them to remind
-- them. lucca santos should be separated because he is not normal to
-- invite."
--
-- Code (game-center.js): a standing call-down (team_auto_invites rider)
-- is folded into Going / Not Going / No Response by their own answer, with
-- the chip on their name, so the RSVP reminders reach them like anyone
-- else; the 🎟 panel keeps per-game call-ups and ↔ Call Ins (Lucca) and
-- only names the standing riders for their ⭐ off switch.  This migration
-- fixes the words: they are call-DOWNS.
UPDATE message_templates SET body = '⭐ Standing Call-down'
 WHERE kind = 'invite_chip' AND tier = 'standing' AND body = '⭐ Standing Call-up';
UPDATE message_templates
   SET body = 'Standing call-down — rides every {team} game automatically and sits in the normal lists; still counts toward the call-down cap in the lineup. Turn it off with the ⭐ in the game''s 🎟 panel.'
 WHERE kind = 'invite_chip' AND tier = 'standing_tip';
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', 'Call-up panel — standing call-downs live in the lists ({names})', 'callup_panel', 'standing_note',
       NULL, '⭐ Standing call-downs are in the lists above with the squad: {names}. Tap ⭐ to stop inviting one automatically.', 1001, true, true, false
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'callup_panel' AND m.tier = 'standing_note');
