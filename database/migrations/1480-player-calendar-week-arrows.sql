-- 1480 (2026-11-18) — Player Calendar: just ‹ › and where you are.
-- Owner 11/18 (cleaning up the player interface): "i think we just need the
-- arrows to go up or back a week. and let them know they are on current
-- week. we don't need date picker or week, month pills".
--
-- Players / parents: ‹  This week · Nov 16 – Nov 22  ›  (green on the
-- current week), "Next week" / "Last week" one step away, the range further
-- out, and "Back to this week" whenever they're off it.  Week view only.
-- Staff keep the date picker and Week / Month.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Event Center', v.label, 'event_center', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Player calendar — the current week', 'wk_this', 'This week · {range}', 1408),
    ('Player calendar — next week',        'wk_next', 'Next week · {range}', 1409),
    ('Player calendar — last week',        'wk_last', 'Last week · {range}', 1410),
    ('Player calendar — jump back',        'wk_back', 'Back to this week',   1411)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'event_center' AND m.tier = v.tier);
