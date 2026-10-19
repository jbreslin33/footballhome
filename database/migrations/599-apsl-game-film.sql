-- 599 (2026-10-19) — APSL game film on Football Home.
--
-- Owner: "can we take this doc and put the links on football home.
-- players should not edit the original doc but you should be able to
-- figure out waht game it is by the date and official apsl website
-- scheudle and the 'home' team as its home team responsibity to upload
-- game film."  And: "the date may not always match up so you got to
-- sometimes use fuzzy logic based on home team and around when it was
-- and schedule."
--
-- The league keeps a shared Google Sheet: one row per uploaded film —
-- a MATCHDAY window, the HOME team (whose duty the upload is), a link.
-- No opponent, no exact date.  Football Home mirrors it read-only:
--
--   film_sources        the sheet(s): csv export url + freshness stamp.
--                       The url is loaded operationally (psql), never
--                       committed — same rule as contacts (never put
--                       third-party links/PII in a migration file).
--   film_links          one row per (home team, link) with the matchday
--                       window as the sheet states it; swept soft on
--                       resync (removed_at) so a sheet edit heals here
--   film_team_aliases   the sheet's short names → the names our APSL
--                       feed (league_fixtures) uses.  NOT club_aliases —
--                       those stay owned by the logos page.
--
-- Matching is FUZZY at read time: the alias resolves the club, and the
-- nearest APSL fixture involving that club within window ±3 days names
-- the game (the feed's home/away flag is NOT trusted — it disagrees
-- with gcal, e.g. 9/30 at VE).  Our feed carries only Lighthouse's
-- games, so other clubs' film lists by matchday + home team.

CREATE TABLE IF NOT EXISTS film_sources (
  id           serial PRIMARY KEY,
  league_label text NOT NULL,
  csv_url      text NOT NULL,
  sheet_url    text,
  is_active    boolean NOT NULL DEFAULT true,
  fetched_at   timestamptz,
  created_at   timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE film_sources IS
  'Game-film link sheets (mig 599): csv export url of the league''s shared sheet. Row loaded operationally, not by migration. Read by FilmSync.';

CREATE TABLE IF NOT EXISTS film_links (
  id             serial PRIMARY KEY,
  source_id      integer NOT NULL REFERENCES film_sources(id) ON DELETE CASCADE,
  matchday_label text,
  window_start   date NOT NULL,
  window_end     date NOT NULL,
  home_team_text text NOT NULL,
  url            text NOT NULL,
  first_seen_at  timestamptz NOT NULL DEFAULT now(),
  last_seen_at   timestamptz NOT NULL DEFAULT now(),
  removed_at     timestamptz,
  UNIQUE (source_id, home_team_text, url)
);
COMMENT ON TABLE film_links IS
  'One game-film link per row as the sheet states it (mig 599): matchday window + home team + url. The game is resolved fuzzily at read time against league_fixtures.';

CREATE TABLE IF NOT EXISTS film_team_aliases (
  alias     text PRIMARY KEY,
  feed_name text NOT NULL
);
COMMENT ON TABLE film_team_aliases IS
  'Sheet short names → league_fixtures home/away names (mig 599). Lowercased alias. Separate from club_aliases, which the logos page owns.';

INSERT INTO film_team_aliases (alias, feed_name) VALUES
  ('ve',                    'Vereinigung Erzgebirge Majors'),
  ('philadelphia heritage', 'Philadelphia Heritage SC'),
  ('ukies',                 'Philadelphia Ukrainian Nationals'),
  ('wc predators',          'WC Predators'),
  ('feelsgood',             'Feelsgood FC'),
  ('medford',               'Medford Strikers'),
  ('oaklyn utd',            'Oaklyn United FC'),
  ('rcnj',                  'Real Central NJ Soccer'),
  ('sewell ob',             'Sewell Old Boys FC'),
  ('westtown',              'Westtown FC'),
  ('persepolis',            'Persepolis United FC'),
  ('vidas',                 'Vidas United FC'),
  ('lighthouse',            'Lighthouse 1893 SC')
ON CONFLICT (alias) DO NOTHING;

-- Copy (kind 'film', client_side).
CREATE OR REPLACE FUNCTION pg_temp.tpl(p_kind text, p_tier text, p_label text, p_body text, p_sort int)
RETURNS void LANGUAGE sql AS $$
  INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
  SELECT 'System', p_label, p_kind, p_tier, NULL, p_body, p_sort, true, true
   WHERE NOT EXISTS (SELECT 1 FROM message_templates WHERE kind = p_kind AND tier = p_tier);
$$;
SELECT pg_temp.tpl('film', 'title',     'Film — title',            '🎥 Game film', 1);
SELECT pg_temp.tpl('film', 'subtitle',  'Film — subtitle',         'APSL game film, straight from the league''s sheet — the home team uploads after each game. Watch here; the sheet itself stays with the league.', 2);
SELECT pg_temp.tpl('film', 'empty',     'Film — nothing yet',      'No film posted yet.', 3);
SELECT pg_temp.tpl('film', 'watch',     'Film — watch button',     'Watch', 4);
SELECT pg_temp.tpl('film', 'unmatched', 'Film — game unknown',     '{home} (home team)', 5);
SELECT pg_temp.tpl('film', 'ours',      'Film — our game label',   '{day} · Lighthouse vs {opponent}', 6);

-- The Men find it on #my next to the GroupMe link.
INSERT INTO chat_links (chat_id, label, url, sort_order)
SELECT 13, '🎥 APSL game film', '#film', 20
 WHERE EXISTS (SELECT 1 FROM chats WHERE id = 13)
   AND NOT EXISTS (SELECT 1 FROM chat_links WHERE chat_id = 13 AND url = '#film');
