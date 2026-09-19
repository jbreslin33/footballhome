-- 384 — Squad game reminder: individual messages with a magic link, and
-- a "subject to change" line.
--
-- Owner 2026-09-19: "can we have both group text/email and individual
-- with magic links? … put disclaimer this is subject to change so if we
-- do change it players understand … dim if sent so we can send again to
-- all or just the ones changed."
--
-- The group message (mig 383) cannot say who is where or sign anyone in.
-- The individual one does both: it names the player's role, and its
-- magic link lands on the game instead of #calendar — so a token can now
-- carry the game it was sent about.
ALTER TABLE magic_link_tokens
    ADD COLUMN IF NOT EXISTS match_id integer REFERENCES matches(id) ON DELETE SET NULL;
COMMENT ON COLUMN magic_link_tokens.match_id IS
    'Game the link was sent about: verify lands on #game-center/<match_id>/starters_bench instead of #calendar.';

-- One row per role and audience.  Tokens: {first} recipient, {child}
-- player (parent tiers), {event}, {where}, {arrival}, {link}, {sender}.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order)
SELECT 'System', v.label, 'squad_notice', v.tier, 'Lighthouse 1893 — game reminder', v.body, v.sort_order
  FROM (VALUES
    ('Game reminder — starter', 'starter_adult', 22,
     E'Hi {first} — game reminder. You''re in the STARTING LINEUP for:\n{event}\n[[Where: {where}\n]][[Arrive by {arrival}\n]]\n'
     'Starting means you''re on the field at kickoff, so be there by the arrival time, ready to warm up.\n\n'
     'The lineup is subject to change — if it does we''ll let you know.\n\n'
     'See the lineup or change your availability, no password needed: {link}\n\n'
     'Can''t make it after all? Set Not Going there right away so we can fill your spot.\n\n— {sender}, Lighthouse 1893'),
    ('Game reminder — bench', 'bench_adult', 23,
     E'Hi {first} — game reminder. You''re ON THE BENCH for:\n{event}\n[[Where: {where}\n]][[Arrive by {arrival}\n]]\n'
     'Bench means you''re in the game-day squad: dressed, warmed up and ready to go on. Be there by the arrival time like everyone else.\n\n'
     'The lineup is subject to change — if it does we''ll let you know.\n\n'
     'See the lineup or change your availability, no password needed: {link}\n\n'
     'Can''t make it after all? Set Not Going there right away so we can fill your spot.\n\n— {sender}, Lighthouse 1893'),
    ('Game reminder — alternate', 'alternate_adult', 24,
     E'Hi {first} — game reminder. You''re an ALTERNATE for:\n{event}\n[[Where: {where}\n]][[Arrive by {arrival}\n]]\n'
     'Alternate means you''re first in if a spot opens in the squad, so please keep the day free — we''ll tell you as soon as one does.\n\n'
     'The lineup is subject to change — if it does we''ll let you know.\n\n'
     'See the lineup or change your availability, no password needed: {link}\n\n'
     'Can''t make it after all? Set Not Going there right away so we know.\n\n— {sender}, Lighthouse 1893'),
    ('Game reminder — starter, parent', 'starter_parent', 25,
     E'Hi {first} — game reminder. {child} is in the STARTING LINEUP for:\n{event}\n[[Where: {where}\n]][[Arrive by {arrival}\n]]\n'
     'Starting means {child} is on the field at kickoff, so please be there by the arrival time, ready to warm up.\n\n'
     'The lineup is subject to change — if it does we''ll let you know.\n\n'
     'See the lineup or change {child}''s availability, no password needed: {link}\n\n'
     'Can''t make it after all? Set Not Going there right away so the coaches can fill the spot.\n\n— {sender}, Lighthouse 1893'),
    ('Game reminder — bench, parent', 'bench_parent', 26,
     E'Hi {first} — game reminder. {child} is ON THE BENCH for:\n{event}\n[[Where: {where}\n]][[Arrive by {arrival}\n]]\n'
     'Bench means {child} is in the game-day squad: dressed, warmed up and ready to go on. Please be there by the arrival time like everyone else.\n\n'
     'The lineup is subject to change — if it does we''ll let you know.\n\n'
     'See the lineup or change {child}''s availability, no password needed: {link}\n\n'
     'Can''t make it after all? Set Not Going there right away so the coaches can fill the spot.\n\n— {sender}, Lighthouse 1893'),
    ('Game reminder — alternate, parent', 'alternate_parent', 27,
     E'Hi {first} — game reminder. {child} is an ALTERNATE for:\n{event}\n[[Where: {where}\n]][[Arrive by {arrival}\n]]\n'
     'Alternate means {child} is first in if a spot opens in the squad, so please keep the day free — we''ll tell you as soon as one does.\n\n'
     'The lineup is subject to change — if it does we''ll let you know.\n\n'
     'See the lineup or change {child}''s availability, no password needed: {link}\n\n'
     'Can''t make it after all? Set Not Going there right away so the coaches know.\n\n— {sender}, Lighthouse 1893')
  ) AS v(label, tier, sort_order, body)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates t WHERE t.kind = 'squad_notice' AND t.tier = v.tier);

-- The group message gets the same disclaimer.
UPDATE message_templates
   SET body = replace(body,
       E'Alternate = first in if a spot opens, so keep the day free.\n\n',
       E'Alternate = first in if a spot opens, so keep the day free.\n\nThe lineup is subject to change — if it does we''ll let you know.\n\n')
 WHERE kind = 'squad_notice' AND tier IN ('group_adult', 'group_parent')
   AND body NOT LIKE '%subject to change%';
