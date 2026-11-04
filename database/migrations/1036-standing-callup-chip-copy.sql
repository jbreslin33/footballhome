-- 1036: the standing-invite card chip names its direction (seen on #teams
-- 2026-11-04: APSL's ⭐ CALL-UPS riders wore "⭐ Standing Call-down").
-- invite_chip/standing stays the call-down wording (a rider from a team
-- higher on the board); standing_up / standing_up_tip are the call-up
-- wording (from a team lower on the board), as the column headings split
-- in mig 1013.

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.category, v.label, 'invite_chip', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Rosters', 'Invite chip — standing invite rider from a lower team (call-up)', 'standing_up', '⭐ Standing Call-up', 881),
    ('Rosters', 'Invite chip — standing call-up tooltip', 'standing_up_tip',
     'Standing call-up — rides every {team} game automatically and sits in the normal lists. Turn it off with the ⭐ in the game''s 🎟 panel.', 882)
  ) AS v(category, label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'invite_chip' AND m.tier = v.tier);
