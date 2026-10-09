-- 554 (2026-10-09) — #dashboard: the Texts cell — who has opted in to club
-- texts.  Owner: "lets add a texts dash cell for who has opted in".
-- GET /api/dashboard counts rostered players per section by the same test
-- the #texts board uses (fh_sms_consented_at for the player or the parent,
-- mig 537); the words live here.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Dashboard', l, 'dashboard', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('texts_title',    'Texts cell — title',                                '💬 Texts', 866),
    ('texts_sub',      'Texts cell — line under the title',                 'Players (or their parent) opted in to club texts', 867),
    ('texts_in',       'Texts cell — under the big number ({n} {of})',      '{n} of {of} opted in', 868),
    ('texts_not_yet',  'Texts cell — have a phone, not opted in ({n})',     '{n} not yet', 869),
    ('texts_nudged',   'Texts cell — of those, nudged ({n})',               '{n} nudged', 870),
    ('texts_no_phone', 'Texts cell — no phone on file ({n})',               '{n} no phone', 871)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'dashboard' AND m.tier = v.t);
-- Owner, same day: "show how many opted in total and percent not how many
-- didn't" — the cell is the percent, the count, and a row per section.
UPDATE message_templates SET is_active = false WHERE kind = 'dashboard' AND tier IN ('texts_not_yet', 'texts_nudged', 'texts_no_phone');
