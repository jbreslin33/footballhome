-- 1924 (2026-11-25): the two sides in the sim are always told apart — change kits + a clash rule.
-- Owner 11/25: "the colors of the teams in sim always need to be distinct no red and diff red etc".
--
-- Until now a game_demo_teams row had ONE kit (mig 639), so Liverpool v Southampton was red v red
-- (and Villa v West Ham claret v claret, Chelsea v Everton blue v blue). Now:
--   game_demo_teams.kit_*         the HOME kit, as before
--   game_demo_team_change_kits    each side's change kits in order (1 = away, 2 = third)
-- The rule lives in the game server (game/src/server/Kits.cpp, chooseKits): the home side wears its
-- home kit; the AWAY side wears the first of its kits whose shirt is in a different colour FAMILY
-- (red incl. claret/maroon/pink, orange, yellow, green, sky, blue incl. navy, purple, white, grey,
-- black; two very dark shirts always clash). Only when none of the away kits works does the home
-- side change too. Baked concept clips are re-kitted in place (fh-concept-clips --rekit), never rebuilt.
--
-- The colours: the real 2015/16 away and third kits, the dominant colour of each part (a hooped or
-- sashed shirt = its base colour, the second colour as trim), from the Wikipedia 2015-16 season-page
-- kit templates checked against footyheadlines / footballfashion / footballkitarchive / club news.
-- `source` credits each row; `confirmed` = two or more sources agree on the shirt (false = one source,
-- or a part of the kit guessed — see the note).

CREATE TABLE IF NOT EXISTS game_demo_team_change_kits (
    team_id    INT NOT NULL REFERENCES game_demo_teams(id) ON DELETE CASCADE,
    kit_order  SMALLINT NOT NULL CHECK (kit_order >= 1),   -- 1 = away, 2 = third
    label      TEXT NOT NULL,                             -- 'away' / 'third'
    shirt      TEXT NOT NULL CHECK (shirt  ~ '^#[0-9a-fA-F]{6}$'),
    shorts     TEXT          CHECK (shorts ~ '^#[0-9a-fA-F]{6}$'),
    socks      TEXT          CHECK (socks  ~ '^#[0-9a-fA-F]{6}$'),
    trim       TEXT          CHECK (trim   ~ '^#[0-9a-fA-F]{6}$'),
    source     TEXT,
    confirmed  BOOLEAN NOT NULL DEFAULT false,
    note       TEXT,
    PRIMARY KEY (team_id, kit_order)
);

INSERT INTO game_demo_team_change_kits (team_id, kit_order, label, shirt, shorts, socks, trim, source, confirmed, note)
SELECT t.id, v.o, v.l, v.sh, v.sr, v.so, v.tr, v.src, v.ok, v.note
  FROM (VALUES
    ('AFC Bournemouth', 1, 'away',  '#1261ab', '#000000', '#000000', '#d71920', 'https://en.wikipedia.org/wiki/2015–16_AFC_Bournemouth_season', false, 'trim guessed; Wikipedia only'),
    ('AFC Bournemouth', 2, 'third', '#ff1493', '#ff1493', '#ff1493', '#ffffff', 'https://en.wikipedia.org/wiki/2015–16_AFC_Bournemouth_season', true,  'pink cancer-charity kit'),
    ('Arsenal',         1, 'away',  '#d2b55b', '#121e52', '#121e52', '#121e52', 'https://en.wikipedia.org/wiki/2015–16_Arsenal_F.C._season', true,  'gold and navy'),
    ('Arsenal',         2, 'third', '#2b2b2e', '#2b2b2e', '#2b2b2e', '#3bc3dd', 'https://en.wikipedia.org/wiki/2015–16_Arsenal_F.C._season', true,  'anthracite, turquoise and gold sashes'),
    ('Aston Villa',     1, 'away',  '#f5e100', '#000000', '#000000', '#000000', 'https://www.footyheadlines.com/2015/07/aston-villa-15-16-kit.html', true, 'Wikipedia gives yellow socks'),
    ('Aston Villa',     2, 'third', '#ffffff', '#84092e', '#ffffff', '#84092e', 'https://en.wikipedia.org/wiki/2015–16_Aston_Villa_F.C._season', false, '2014-15 white away reused; one source'),
    ('Chelsea',         1, 'away',  '#ffffff', '#ffffff', '#0a3d91', '#d71920', 'https://en.wikipedia.org/wiki/2015–16_Chelsea_F.C._season', false, 'trim unconfirmed'),
    ('Chelsea',         2, 'third', '#111111', '#111111', '#111111', '#d71920', 'https://en.wikipedia.org/wiki/2015–16_Chelsea_F.C._season', false, 'trim unconfirmed'),
    ('Crystal Palace',  1, 'away',  '#ffffff', '#ffffff', '#ffffff', '#c8102e', 'https://www.footyheadlines.com/2015/05/crystal-palace-15-16-kits.html', true, 'white, red and blue central sash'),
    ('Crystal Palace',  2, 'third', '#ffe600', '#76ccff', '#76ccff', '#1b458f', 'https://en.wikipedia.org/wiki/2015–16_Crystal_Palace_F.C._season', false, '2014-15 yellow away reused; one source'),
    ('Everton',         1, 'away',  '#ffffff', '#000000', '#ffffff', '#274488', 'https://en.wikipedia.org/wiki/2015–16_Everton_F.C._season', false, 'trim unconfirmed'),
    ('Everton',         2, 'third', '#314927', '#2c4b21', '#2c4b21', '#f08a24', 'https://en.wikipedia.org/wiki/2015–16_Everton_F.C._season', true,  'green and orange'),
    ('Leicester City',  1, 'away',  '#111111', '#111111', '#111111', '#c9a54b', 'https://en.wikipedia.org/wiki/2015–16_Leicester_City_F.C._season', true, 'black and gold'),
    ('Leicester City',  2, 'third', '#ffffff', '#ffffff', '#ffffff', '#1b3f94', 'https://en.wikipedia.org/wiki/2015–16_Leicester_City_F.C._season', true, 'white and blue'),
    ('Liverpool',       1, 'away',  '#ffffff', '#ffffff', '#ffffff', '#c8102e', 'https://www.footyheadlines.com/2015/06/liverpool-15-16-away-kit.html', true, 'all white, red collar'),
    ('Liverpool',       2, 'third', '#111111', '#111111', '#111111', '#c8102e', 'https://www.footyheadlines.com/2015/05/new-balance-liverpool-15-16-third-kit.html', true, 'black polo'),
    ('Manchester City', 1, 'away',  '#0f1a3a', '#0f1a3a', '#0f1a3a', '#4fc3e8', 'https://en.wikipedia.org/wiki/2015–16_Manchester_City_F.C._season', true, 'navy, chlorine-blue trim'),
    ('Manchester City', 2, 'third', '#d3fe7a', '#d3fe7a', '#d3fe7a', '#111111', 'https://en.wikipedia.org/wiki/2015–16_Manchester_City_F.C._season', true, 'ghost green'),
    ('Manchester United',1,'away',  '#ffffff', '#000000', '#ffffff', '#000000', 'https://en.wikipedia.org/wiki/2015–16_Manchester_United_F.C._season', true, NULL),
    ('Manchester United',2,'third', '#111111', '#111111', '#ffffff', '#f26522', 'https://en.wikipedia.org/wiki/2015–16_Manchester_United_F.C._season', false, 'white socks Wikipedia only'),
    ('Newcastle United',1, 'away',  '#c9cdd1', '#3bb9ff', '#c9cdd1', '#3bb9ff', 'https://footballfashion.org/wordpress/2015/07/30/newcastle-united-201516-puma-away-kit/', true, 'light grey, Hawaiian blue shorts'),
    ('Newcastle United',2, 'third', '#171739', '#171739', '#171739', '#e86fa3', 'https://www.footyheadlines.com/2015/06/newcastle-united-15-16-third-kit.html', true, 'dark blue, pink and white sash'),
    ('Norwich City',    1, 'away',  '#028644', '#fff200', '#028644', '#fff200', 'https://footballfashion.org/wordpress/2015/07/17/norwich-city-fc-201516-errea-away-kit/', true, 'green, yellow pinstripes'),
    ('Norwich City',    2, 'third', '#f2d21a', '#000000', '#000000', '#009933', 'https://www.footyheadlines.com/2015/07/norwich-city-15-16-third-kit-is-made-to-be-hated.html', false, 'yellow/green/orange hoops; black shorts+socks one source'),
    ('Southampton',     1, 'away',  '#1e9e48', '#000036', '#1e9e48', '#000036', 'https://en.wikipedia.org/wiki/2015–16_Southampton_F.C._season', true, 'green, dark blue sash'),
    ('Southampton',     2, 'third', '#000060', '#000060', '#000060', '#f2c500', 'https://en.wikipedia.org/wiki/2015–16_Southampton_F.C._season', false, '2014-15 away reused; trim guessed'),
    ('Stoke City',      1, 'away',  '#111111', '#111111', '#111111', '#2fa84f', 'https://www.footyheadlines.com/2015/04/new-balance-stoke-city-15-16-kits.html', true, 'black, green sash'),
    ('Stoke City',      2, 'third', '#ffffff', '#ffffff', '#ffffff', '#e03a3e', 'https://www.footyheadlines.com/2016/02/special-stoke-city-15-16-third-kit.html', false, 'shorts and socks unconfirmed'),
    ('Sunderland',      1, 'away',  '#00a651', '#00a651', '#00a651', '#f5e400', 'https://en.wikipedia.org/wiki/2015–16_Sunderland_A.F.C._season', true, 'green fading to yellow'),
    ('Swansea City',    1, 'away',  '#1b2a4a', '#6fd13b', '#6fd13b', '#6fd13b', 'https://www.swanseacity.com/news/swans-launch-new-away-kit', false, 'navy, green hoops; green shorts+socks Wikipedia only'),
    ('Tottenham Hotspur',1,'away',  '#2f63b0', '#17182c', '#17182c', '#17182c', 'https://footyheadlines.com/2015/05/tottenham-hotspur-15-16-away-kit.html', false, 'blue, navy hoops; shade disputed'),
    ('Tottenham Hotspur',2,'third', '#2c1947', '#2c1947', '#2c1947', '#9a9ca0', 'https://www.footyheadlines.com/2015/07/tottenham-hotspur-15-16-third-kit.html', true, 'purple'),
    ('Watford',         1, 'away',  '#111111', '#111111', '#111111', '#ffffff', 'https://footballfashion.org/wordpress/2015/08/02/watford-fc-201516-puma-away-kit', true, 'black'),
    ('West Bromwich Albion',1,'away','#ba0000', '#000000', '#ba0000', '#000000', 'https://en.wikipedia.org/wiki/2015–16_West_Bromwich_Albion_F.C._season', true, 'red, black pinstripes'),
    ('West Ham United', 1, 'away',  '#7acbe5', '#7acbe5', '#7acbe5', '#7a263a', 'https://en.wikipedia.org/wiki/2015–16_West_Ham_United_F.C._season', false, 'sky blue Wikipedia only; trim guessed'),
    ('West Ham United', 2, 'third', '#00002e', '#00002e', '#00002e', '#7acbe5', 'https://en.wikipedia.org/wiki/2015–16_West_Ham_United_F.C._season', false, 'navy Wikipedia only; trim guessed')
  ) AS v(team, o, l, sh, sr, so, tr, src, ok, note)
  JOIN game_demo_teams t ON t.name = v.team
ON CONFLICT (team_id, kit_order) DO UPDATE
   SET label = EXCLUDED.label, shirt = EXCLUDED.shirt, shorts = EXCLUDED.shorts, socks = EXCLUDED.socks,
       trim = EXCLUDED.trim, source = EXCLUDED.source, confirmed = EXCLUDED.confirmed, note = EXCLUDED.note;
