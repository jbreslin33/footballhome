-- 1494 (2026-11-18) — Your availability: just the two boxes.  Owner 11/18:
-- "just leave the boxes GOING NOT GOING. and no other words" → "simple".
--   [GOING] [NOT GOING]   — the filled one is the answer; no "Going?" label
-- (a parent's line per kid keeps the kid's name).
UPDATE message_templates SET body = 'GOING', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'answer_yes';
UPDATE message_templates SET body = 'NOT GOING', updated_at = now()
 WHERE kind = 'event_center' AND tier = 'answer_no';
