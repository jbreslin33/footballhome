-- 1914 (2026-11-25): the concept viewer plays like a video — from 0:00 at 1×, the concept's room running the match
-- ahead at 4× so the recording and the concept's spells are found before the playhead gets there.
-- Owner 11/25: "the video controls are terrible it shoud start and 0 seconds. looks like its always at end?"
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'Football', 'Concept viewer — ' || v.l, 'taxonomy', v.t, NULL, v.b, v.o, true, true
  FROM (VALUES
    ('clock: played / recorded ({t},{total})', 'view_clock', '{t} / {total}', 494),
    ('jump to the newest moment', 'view_go_newest', 'Newest ›', 495)
  ) AS v(l, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'taxonomy' AND m.tier = v.t);

-- The tally line pointed at a green/red bar; the bar marks his spells in gold.
UPDATE message_templates SET body = 'This recording, #{num} while in it: in reach {pin}% · out of reach {pout}% (gold on the bar = when he is in it)'
 WHERE kind = 'taxonomy' AND tier = 'focus_pd_tally';
