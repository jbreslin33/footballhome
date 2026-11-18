-- 1459 (2026-11-18) — 📅 Calendar: an unanswered event shouts, with its fine.
-- Owner 11/18 (viewing as a player): "the player calendar page needs a
-- little work. it needs to be really clear they have not set availability
-- and how important that is. maybe show fine as label if they don't set it".
--
-- The feed now carries my_rsvp_fine_usd per event (CalendarController,
-- fh_person_fines_all's rules for the viewer: Men $1 practice / $3 game
-- today; NULL for youth, women, coaches, volunteers, parents).  An
-- unanswered tile gets an amber frame and one of the lines below; a strip
-- over the week counts what is still open and the fines at stake.
UPDATE message_templates SET body = '⚠️ Set your availability — the coach is counting on it', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'me_status_none';
UPDATE message_templates SET body = '⚠️ Set {name}''s availability — the coach is counting on it', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'kid_status_none';

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Calendar tile — unanswered, with the fine',           'me_status_none_fine', '⚠️ Set your availability — {amount} fine if you don''t', 1340),
    ('Calendar strip — one of your events unanswered',      'need_one',            '⚠️ You haven''t set your availability for 1 event', 1341),
    ('Calendar strip — several of your events unanswered',  'need_many',           '⚠️ You haven''t set your availability for {n} events', 1342),
    ('Calendar strip — a child''s events unanswered',       'need_kid',            '⚠️ {name}: {n} to answer', 1343),
    ('Calendar strip — the fines at stake',                 'need_fines',          '💸 {total} in fines if they stay unanswered — answer before each one starts.', 1344),
    ('Calendar strip — how',                                'need_how',            'Tap ✓ going or ✗ not going on each one below. Your coach builds the squad from it.', 1345)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
