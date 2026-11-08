-- 1180 (2026-11-07) — Weekend slideshow caption says "this week" when a
-- weekday game is in it.  Owner: "could it say games this week if weekday
-- game added?"  WeekendSlides._caption picks caption_week_head_<type> when
-- any chosen game is Mon–Thu, else caption_head_<type> (mig 1179).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'System', v.label, 'weekend_slides', v.tier, NULL, v.body, v.sort, true, true
  FROM (VALUES
    ('caption_week_head_game_day',       'Weekend slideshow — announcements caption head (weekday game in it)', '⚽ GAMES THIS WEEK', 21),
    ('caption_week_head_starters_bench', 'Weekend slideshow — lineups caption head (weekday game in it)',       '⚔️ THIS WEEK''S LINEUPS', 22)
  ) AS v(tier, label, body, sort)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'weekend_slides' AND m.tier = v.tier);
