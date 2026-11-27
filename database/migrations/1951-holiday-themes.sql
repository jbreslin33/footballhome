-- 1951 (2026-11-26) — 🎉 Holiday themes: the app dresses for each holiday.
-- Owner: "can we get a holiday theme for each holiday for fh? like its
-- thanks giving now then shift to christmas and jewish and muslim holidays
-- and new year valentine saint patrick etc".
--
-- holiday_themes      one row per holiday: its look (accent colours, the
--                     emoji that drift down once per visit) and greeting.
-- holiday_theme_dates the days each one shows, per year — movable feasts
--                     (Easter, Hanukkah, Ramadan, Eids, Lunar New Year,
--                     Diwali …) can't be computed, so every year is a row.
--                     Islamic dates hang on the moon sighting: ±1 day.
-- fh_holiday_themes_on(d) the themes live on a day, shortest window first
--                     (ties: sort_order — Christmas before Hanukkah)
--                     (Valentine's beats Ramadan on the 14th; the app takes
--                     the first one's colours and shows every greeting).
--
-- Served by GET /api/public/holiday-theme (no sign-in: the public pages
-- dress too), drawn by frontend/js/lib/holiday-theme.js.
-- Add a year = INSERT holiday_theme_dates rows by migration.

CREATE TABLE IF NOT EXISTS holiday_themes (
    code        text PRIMARY KEY,
    name        text NOT NULL,
    emoji       text NOT NULL,
    greeting    text NOT NULL,
    accent      text NOT NULL,              -- replaces --accent (lighthouse yellow)
    accent2     text NOT NULL,              -- second colour of the band
    decor       text[] NOT NULL DEFAULT '{}', -- drift down once per visit; {} = none (solemn days)
    sort_order  int  NOT NULL DEFAULT 100,
    is_active   boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS holiday_theme_dates (
    id          serial PRIMARY KEY,
    theme_code  text NOT NULL REFERENCES holiday_themes(code) ON DELETE CASCADE,
    starts_on   date NOT NULL,
    ends_on     date NOT NULL,
    CHECK (ends_on >= starts_on),
    UNIQUE (theme_code, starts_on)
);

INSERT INTO holiday_themes (code, name, emoji, greeting, accent, accent2, decor, sort_order) VALUES
 ('thanksgiving',    'Thanksgiving',       '🦃', 'Happy Thanksgiving from Lighthouse 1893 — grateful for every one of you', '#f0a040', '#b5562b', '{🍂,🍁,🦃,🥧}', 10),
 ('hanukkah',        'Hanukkah',           '🕎', 'Happy Hanukkah — Chag Sameach!',                    '#7cc4ff', '#dfe8f5', '{🕎,✡️,💙,✨}', 20),
 ('christmas',       'Christmas',          '🎄', 'Merry Christmas from Lighthouse 1893!',             '#ff5a5f', '#2fae66', '{❄️,🎄,⭐,❄️,🎁}', 15),
 ('kwanzaa',         'Kwanzaa',            '🕯️', 'Happy Kwanzaa!',                                   '#ff5a5f', '#2fae66', '{🕯️}', 40),
 ('new_year',        'New Year',           '🎆', 'Happy New Year! Here''s to a great year on the pitch', '#ffd166', '#d9d9e8', '{🎆,✨,🎉,🥂}', 50),
 ('lunar_new_year',  'Lunar New Year',     '🧧', 'Happy Lunar New Year!',                             '#ff5a5f', '#ffd166', '{🧧,🏮,✨}', 60),
 ('ramadan',         'Ramadan',            '🌙', 'Ramadan Mubarak to all our fasting players and families', '#e9c46a', '#2a9d8f', '{🌙,⭐,🏮}', 70),
 ('eid_al_fitr',     'Eid al-Fitr',        '🌙', 'Eid Mubarak!',                                      '#2ec4b6', '#e9c46a', '{🌙,✨,⭐}', 80),
 ('valentines',      'Valentine''s Day',   '❤️', 'Happy Valentine''s Day — we love the beautiful game', '#ff6b9a', '#ffb3c8', '{❤️,💕,💙}', 90),
 ('st_patricks',     'St. Patrick''s Day', '☘️', 'Happy St. Patrick''s Day!',                         '#3ddc84', '#ffd166', '{☘️,🍀}', 100),
 ('easter',          'Easter',             '🐣', 'Happy Easter from Lighthouse 1893!',                '#c9a7ff', '#ffe066', '{🐣,🌷,🥚}', 110),
 ('passover',        'Passover',           '🍷', 'Chag Pesach Sameach — Happy Passover!',             '#7cb2ff', '#e9d8a6', '{🍷,✨}', 120),
 ('mothers_day',     'Mother''s Day',      '💐', 'Happy Mother''s Day to every soccer mom!',          '#ff8fab', '#ffc2d1', '{💐,🌸}', 130),
 ('eid_al_adha',     'Eid al-Adha',        '🌙', 'Eid al-Adha Mubarak!',                              '#2ec4b6', '#e9c46a', '{🌙,✨}', 140),
 ('memorial_day',    'Memorial Day',       '🇺🇸', 'Honoring those who served — Memorial Day',          '#ff5a5f', '#e8f0ff', '{}', 150),
 ('juneteenth',      'Juneteenth',         '✊', 'Happy Juneteenth — Freedom Day',                    '#ff5a5f', '#2fae66', '{}', 160),
 ('fathers_day',     'Father''s Day',      '👔', 'Happy Father''s Day to every soccer dad!',          '#5aa0ff', '#f5c842', '{⚽,💙}', 170),
 ('independence',    'Independence Day',   '🎇', 'Happy 4th of July!',                                '#ff5a5f', '#5aa0ff', '{🎆,🎇,⭐}', 180),
 ('labor_day',       'Labor Day',          '💪', 'Happy Labor Day!',                                  '#f5c842', '#5aa0ff', '{}', 190),
 ('rosh_hashanah',   'Rosh Hashanah',      '🍎', 'Shana Tova — a sweet new year!',                    '#e9c46a', '#ff5a5f', '{🍎,🍯}', 200),
 ('yom_kippur',      'Yom Kippur',         '🕊️', 'G''mar Chatimah Tovah',                             '#e8f0ff', '#9fb4d9', '{}', 210),
 ('diwali',          'Diwali',             '🪔', 'Happy Diwali — the festival of lights!',            '#ff9f1c', '#ffd166', '{🪔,✨}', 220),
 ('halloween',       'Halloween',          '🎃', 'Happy Halloween from Lighthouse 1893!',             '#ff7a1a', '#a066d3', '{🎃,👻,🦇}', 230)
ON CONFLICT (code) DO NOTHING;

INSERT INTO holiday_theme_dates (theme_code, starts_on, ends_on) VALUES
 -- 2026-27 season
 ('thanksgiving',   '2026-11-22', '2026-11-29'),
 ('hanukkah',       '2026-12-04', '2026-12-12'),   -- evening Dec 4 – Dec 12
 ('christmas',      '2026-12-18', '2026-12-26'),
 ('kwanzaa',        '2026-12-26', '2027-01-01'),
 ('new_year',       '2026-12-30', '2027-01-02'),
 ('lunar_new_year', '2027-02-05', '2027-02-08'),   -- Feb 6, Year of the Goat
 ('ramadan',        '2027-02-08', '2027-03-09'),   -- moon sighting ±1
 ('valentines',     '2027-02-12', '2027-02-14'),
 ('eid_al_fitr',    '2027-03-10', '2027-03-12'),   -- moon sighting ±1
 ('st_patricks',    '2027-03-14', '2027-03-17'),
 ('easter',         '2027-03-26', '2027-03-28'),   -- Good Friday – Easter Sunday
 ('passover',       '2027-04-21', '2027-04-29'),   -- evening Apr 21 – Apr 29
 ('mothers_day',    '2027-05-08', '2027-05-09'),
 ('eid_al_adha',    '2027-05-16', '2027-05-18'),   -- moon sighting ±1
 ('memorial_day',   '2027-05-29', '2027-05-31'),
 ('juneteenth',     '2027-06-19', '2027-06-19'),
 ('fathers_day',    '2027-06-19', '2027-06-20'),
 ('independence',   '2027-07-02', '2027-07-05'),   -- 4th is a Sunday, observed Mon 5th
 ('labor_day',      '2027-09-04', '2027-09-06'),
 ('rosh_hashanah',  '2027-10-01', '2027-10-03'),   -- evening Oct 1 – Oct 3 (5788)
 ('yom_kippur',     '2027-10-10', '2027-10-11'),
 ('halloween',      '2027-10-24', '2027-10-31'),
 ('diwali',         '2027-10-28', '2027-10-30'),   -- Oct 29
 ('thanksgiving',   '2027-11-21', '2027-11-28'),
 ('christmas',      '2027-12-18', '2027-12-26'),
 ('hanukkah',       '2027-12-24', '2028-01-01'),   -- evening Dec 24 – Jan 1
 ('kwanzaa',        '2027-12-26', '2028-01-01'),
 ('new_year',       '2027-12-30', '2028-01-02')
ON CONFLICT (theme_code, starts_on) DO NOTHING;

-- Themes live on day d: shortest window first, then sort_order.
CREATE OR REPLACE FUNCTION fh_holiday_themes_on(d date)
RETURNS TABLE (code text, name text, emoji text, greeting text,
               accent text, accent2 text, decor text[])
LANGUAGE sql STABLE AS $$
    SELECT t.code, t.name, t.emoji, t.greeting, t.accent, t.accent2, t.decor
      FROM holiday_theme_dates hd
      JOIN holiday_themes t ON t.code = hd.theme_code AND t.is_active
     WHERE d BETWEEN hd.starts_on AND hd.ends_on
     ORDER BY (hd.ends_on - hd.starts_on), t.sort_order;
$$;
