-- 833 (2026-10-29) — #apsl becomes the APSL section's hub.
--
-- Owner: "leagues and opponents section should have apsl section. then
-- from there the messaging section and the pyramid section etc. we need
-- to be organize".  Same shape as the #casa hub (mig 486): the role
-- picker's APSL tile opens #apsl, a page of tiles —
--   ✉️ Commissioner & messages  #apsl-messages  league office contacts +
--                                the roster-moves email (mig 829)
--   🔺 Pyramid & tables         #apsl-pyramid   (was #apsl, migs 819/823)
--   📇 APSL opponents           #opponents on the APSL pill
-- Tiles: subject = label, body = description (as kind 'casa').

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'APSL', l, 'apsl', t, s, b, o, true, true, false
  FROM (VALUES
    ('hub_title',      '#apsl hub — page title',    NULL, '🔺 APSL', 10),
    ('hub_subtitle',   '#apsl hub — under the title', NULL, 'Our league section — the commissioner, roster moves, the pyramid and the clubs we play.', 11),
    ('tile_messages',  '#apsl hub — messaging tile', '✉️ Commissioner & messages',
     'The league office — email or text, and the roster moves to send', 12),
    ('tile_moves_n',   '#apsl hub — messaging tile, moves waiting', NULL, ' · {n} roster moves to send', 13),
    ('tile_pyramid',   '#apsl hub — pyramid tile', '🔺 Pyramid & tables',
     'Every conference and feeder league, live tables, promotion and relegation', 14),
    ('tile_opponents', '#apsl hub — opponents tile', '📇 APSL opponents',
     'The clubs in our conference — text or email their managers', 15),
    ('messages_title', '#apsl-messages — page title', NULL, '✉️ APSL commissioner & messages', 16),
    ('contacts_h',     '#apsl-messages — contacts heading', NULL, 'League office', 17),
    ('no_contacts',    '#apsl-messages — no league contacts', NULL, 'No league office contact yet — add one on #opponents (APSL › League office).', 18),
    ('no_moves',       '#apsl-messages — nothing to send', NULL, 'No roster moves to send — the #teams Roster pill matches the league''s lists.', 19)
  ) AS v(t, l, s, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'apsl' AND m.tier = v.t);

-- The role picker tile now opens the whole section, not just the pyramid.
UPDATE message_templates SET body = 'APSL'
 WHERE kind = 'apsl_pyramid' AND tier = 'tile_title' AND body = 'APSL Pyramid';
UPDATE message_templates SET body = 'Commissioner & roster moves, the pyramid, the clubs we play'
 WHERE kind = 'apsl_pyramid' AND tier = 'tile_sub';
