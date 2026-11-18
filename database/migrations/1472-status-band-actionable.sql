-- 1472 (2026-11-18) — 🚦 Status band: every item says what to do, with a button.
-- Owner 11/18: "it needs to be more actionable and clear" → "Overdue dues
-- pay now button? missing x rsvps do so below?" → "amount fined so far?" →
-- "amount they will be fined if they don't set availability this week".
--
-- One short segment per item: a label (seg_<code>) + a button (act_<code>):
--   ⛔ Overdue dues $70 [Pay now ›]                → the LA payment page
--   ⛔ Missing 8 RSVPs · $11 in fines if not set [Answer below ›]
--                                                  → the list, ✓ / ✗ on each row
--   Fined so far $4 ›                              → the fines
--   3 new messages ›                               → the chat
-- Red while anything to do is left; "✓ All set" in green otherwise.
-- Tokens: {total} RSVPs missing, {n} of them soon, {hours} the window,
-- {stake} the fines riding on this week's, {amount} money.
UPDATE message_templates SET body = '✓ All set', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'status_ok';
UPDATE message_templates SET body = '⚠️ Set your availability — tap ✓ going or ✗ not going', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'need_title';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Status band — RSVPs missing, some soon',             'seg_rsvp_soon',       '⛔ Missing {total} RSVPs — {n} in the next {hours}h',                         1380),
    ('Status band — RSVPs missing, some soon, with fines', 'seg_rsvp_soon_fine',  '⛔ Missing {total} RSVPs — {n} in the next {hours}h · {stake} in fines if not set', 1381),
    ('Status band — RSVPs missing',                        'seg_rsvp_open',       '⛔ Missing {total} RSVPs',                                                   1382),
    ('Status band — RSVPs missing, with fines',            'seg_rsvp_open_fine',  '⛔ Missing {total} RSVPs · {stake} in fines if not set',                     1383),
    ('Status band — RSVPs button (soon)',                  'act_rsvp_soon',       'Answer below ›',                                                            1384),
    ('Status band — RSVPs button',                         'act_rsvp_open',       'Answer below ›',                                                            1385),
    ('Status band — blocked for dues',                     'seg_dues_blocked',    '⛔ Can''t play — overdue dues {amount}',                                     1386),
    ('Status band — blocked: pay',                         'act_dues_blocked',    'Pay now ›',                                                                 1387),
    ('Status band — dues owed',                            'seg_dues_owed',       '⛔ Overdue dues {amount}',                                                   1388),
    ('Status band — dues: pay',                            'act_dues_owed',       'Pay now ›',                                                                 1389),
    ('Status band — fines so far (button)',                'act_fines_owed',      'Fined so far {amount} ›',                                                   1390),
    ('Status band — unread chat (button)',                 'act_chat_unread',     '{n} new messages ›',                                                        1391),
    ('Status band — suspended (button)',                   'act_suspended',       'Suspended ›',                                                               1392)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
