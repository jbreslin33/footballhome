-- 1179 (2026-11-07) — Weekend slideshows: one Instagram carousel post with a
-- slide per game.  Owner: "can we do the posts as a slide show for game
-- announcements. like a button somewhere appropriate to post a slide show of
-- all games that weekend for game announcements? then also one for lineup?
-- even though kids dont' have one and women don't we can include them again
-- as the game announcement".
--
-- Two buttons on #game-center (staff who may post): 🎞 Game Announcements and
-- 🎞 Lineups.  The browser draws each slide with the same
-- SocialPostCard.buildCardHtml the single posts use; a Lineups slide for a
-- game with no lineup (kids' everyone-plays games, the women) is that game's
-- announcement card instead.  SocialController publishes the carousel
-- (/api/social/carousels…).
--
-- One carousel per (post type, week, platform): the week is its Monday, the
-- same week #game-center's game switcher shows.

CREATE TABLE IF NOT EXISTS social_carousels (
  id                SERIAL PRIMARY KEY,
  post_type_id      INT NOT NULL REFERENCES social_post_types(id),
  week_start        DATE NOT NULL CHECK (EXTRACT(ISODOW FROM week_start) = 1),
  platform          VARCHAR(50) NOT NULL DEFAULT 'instagram',
  caption           TEXT,
  status            VARCHAR(20) NOT NULL DEFAULT 'draft'
                    CHECK (status IN ('draft', 'publishing', 'posted', 'error')),
  posted_at         TIMESTAMPTZ,
  external_media_id VARCHAR(200),
  error_message     TEXT,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (post_type_id, week_start, platform)
);

-- The slides in order.  slide_post_type_id is what the slide draws: the
-- carousel's own type, or game_day where a Lineups slide fell back.
CREATE TABLE IF NOT EXISTS social_carousel_slides (
  carousel_id        INT NOT NULL REFERENCES social_carousels(id) ON DELETE CASCADE,
  position           SMALLINT NOT NULL CHECK (position BETWEEN 1 AND 10),
  match_id           INT NOT NULL REFERENCES matches(id) ON DELETE CASCADE,
  slide_post_type_id INT NOT NULL REFERENCES social_post_types(id),
  image_path         TEXT,
  image_url          TEXT,
  PRIMARY KEY (carousel_id, position),
  UNIQUE (carousel_id, match_id)
);

-- Wording (client_side rows, MessageCopy.block('weekend_slides', tier)).
CREATE OR REPLACE FUNCTION pg_temp.add_client_tpl(p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, 'weekend_slides', p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = 'weekend_slides' AND tier = p_tier);
$$;

SELECT pg_temp.add_client_tpl('button_game_day', 'Weekend slideshow — announcements button',
  '🎞 Weekend slideshow — Game Announcements', 1);
SELECT pg_temp.add_client_tpl('button_starters_bench', 'Weekend slideshow — lineups button',
  '🎞 Weekend slideshow — Lineups', 2);
SELECT pg_temp.add_client_tpl('hint', 'Weekend slideshow — panel hint',
  'One Instagram post with a slide per game. Untick a game to leave it out (Instagram takes up to 10 slides).', 3);
SELECT pg_temp.add_client_tpl('hint_starters_bench', 'Weekend slideshow — lineups hint',
  'A game with no lineup set (kids, women) gets its Game Announcement slide instead.', 4);
SELECT pg_temp.add_client_tpl('fallback_chip', 'Weekend slideshow — announcement slide chip',
  '📣 Announcement (no lineup)', 5);
SELECT pg_temp.add_client_tpl('none', 'Weekend slideshow — no games',
  'No games this weekend.', 6);
SELECT pg_temp.add_client_tpl('too_many', 'Weekend slideshow — too many slides',
  'Instagram takes at most 10 slides — untick {extra} game{plural}.', 7);
SELECT pg_temp.add_client_tpl('building', 'Weekend slideshow — building',
  '⏳ Drawing slide {n} of {count}…', 8);
SELECT pg_temp.add_client_tpl('post_button', 'Weekend slideshow — post button',
  '📸 Post slideshow to Instagram ({count} slides)', 9);
SELECT pg_temp.add_client_tpl('confirm', 'Weekend slideshow — confirm',
  'Post this {count}-slide slideshow to Instagram now?', 10);
SELECT pg_temp.add_client_tpl('uploading', 'Weekend slideshow — uploading',
  '⏳ Uploading slide {n} of {count}…', 11);
SELECT pg_temp.add_client_tpl('publishing', 'Weekend slideshow — publishing',
  '⏳ Publishing to Instagram (about a minute)…', 12);
SELECT pg_temp.add_client_tpl('posted', 'Weekend slideshow — posted mark',
  '✅ Posted {when}', 13);
SELECT pg_temp.add_client_tpl('done', 'Weekend slideshow — done',
  'Posted to Instagram! 🎉', 14);
SELECT pg_temp.add_client_tpl('failed', 'Weekend slideshow — failed',
  'Could not post: {reason}', 15);
SELECT pg_temp.add_client_tpl('caption_head_game_day', 'Weekend slideshow — announcements caption head',
  '⚽ GAMES THIS WEEKEND', 16);
SELECT pg_temp.add_client_tpl('caption_head_starters_bench', 'Weekend slideshow — lineups caption head',
  '⚔️ WEEKEND LINEUPS', 17);
SELECT pg_temp.add_client_tpl('caption_line', 'Weekend slideshow — caption line per game',
  E'{game}\n📅 {day} · ⏰ {time}\n📍 {venue}', 18);
SELECT pg_temp.add_client_tpl('caption_tail', 'Weekend slideshow — caption hashtags',
  E'Swipe for every game ➡️\n\n#Lighthouse1893 #PhillySoccer #GameDay', 19);
SELECT pg_temp.add_client_tpl('caption_label', 'Weekend slideshow — caption box label',
  'Caption', 20);
