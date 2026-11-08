-- 1181 (2026-11-07) — Weekend slideshow caption heading carries the number
-- of games.  Owner: "can we say 9 Games this week or whatever the total is?"
-- Tokens filled by WeekendSlides._caption: {count} = slides in the post,
-- {s} = 'S' unless it is one game.
UPDATE message_templates SET body = v.body
  FROM (VALUES
    ('caption_head_game_day',            '⚽ {count} GAME{s} THIS WEEKEND'),
    ('caption_week_head_game_day',       '⚽ {count} GAME{s} THIS WEEK'),
    ('caption_head_starters_bench',      '⚔️ LINEUPS · {count} GAME{s} THIS WEEKEND'),
    ('caption_week_head_starters_bench', '⚔️ LINEUPS · {count} GAME{s} THIS WEEK')
  ) AS v(tier, body)
 WHERE message_templates.kind = 'weekend_slides' AND message_templates.tier = v.tier;
