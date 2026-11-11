-- 1239: ✓ Mark all present (owner 2026-11-11: "we need a mark all present
-- right? then i can deselect the absent").  One button over the Going
-- section of Event Center from the event's day on: every Going player
-- (and invited / available) who has no attendance yet → Present.  The
-- coach then taps A (or the lit P to clear) on whoever didn't show.
-- Only for people who may mark the event (can_mark).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT v.c, v.l, v.k, v.t, NULL, v.b, v.o, true, true, false
  FROM (VALUES
    ('Event Center', 'Button over Going — mark the unmarked present ({n})', 'event_center', 'mark_all_present', '✓ Mark all {n} present', 1239),
    ('Event Center', 'Note beside the mark-all button',                     'event_center', 'mark_all_present_note', 'then tap A on whoever didn''t show', 1240)
  ) AS v(c, l, k, t, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = v.k AND m.tier = v.t);
