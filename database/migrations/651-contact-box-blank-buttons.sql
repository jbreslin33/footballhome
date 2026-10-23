-- 651 (2026-10-23) — the blank text / blank email shortcuts move into the
-- card's MANUAL box (mig 649).
-- Owner 2026-10-16 asked for a blank compose on every card ("also one that
-- is blank so i can send quick message") — it was a separate chip line
-- with the phone and email; with the two contact boxes that line doubled
-- the contact info, so the blank compose now lives in MANUAL and the chip
-- line shows only on cards without the boxes.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Game Center', v.l, 'contact_box', v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('blank_sms',       'Card — blank text from your phone',  '💬 BLANK', 944),
    ('blank_email',     'Card — blank email',                 '✉ BLANK',  945),
    ('blank_tip',       'Card — blank compose hover ({to})',  'Blank message to {to} — your own words, nothing pre-written', 946)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'contact_box' AND m.tier = v.t);
