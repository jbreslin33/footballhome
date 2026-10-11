-- 564 (2026-10-11) — #cup-rosters: a choice of cups.
-- Owner: "we should have choice of cups but this is usasa amateur cup".
--
-- The sheet's CUP header field becomes a dropdown fed from cup_options
-- (add or retire a cup by migration, never in code); the sheet still
-- stores the chosen name as text, so an old sheet keeps saying what it
-- said when it was filed.  The form we reproduce is the USASA Region I
-- Player Pool, and the cup we file it for today is the USASA Amateur
-- Cup — so that becomes the first-sheet default in place of US Open Cup.
CREATE TABLE IF NOT EXISTS cup_options (
    id          SERIAL PRIMARY KEY,
    name        TEXT NOT NULL UNIQUE,
    sort_order  INTEGER NOT NULL DEFAULT 0,
    is_active   BOOLEAN NOT NULL DEFAULT true
);
COMMENT ON TABLE cup_options IS 'mig 564: the cups a #cup-rosters sheet can be filed for — the Cup dropdown; add/retire rows by migration.';

INSERT INTO cup_options (name, sort_order) VALUES
    ('USASA Amateur Cup',      10),
    ('US Open Cup',            20),
    ('Werner Fricker Open Cup', 30),
    ('USASA Over-30 Cup',      40),
    ('USASA Over-40 Cup',      50)
ON CONFLICT (name) DO NOTHING;

-- The first-sheet default cup (message_templates, mig 556) and any sheet
-- still carrying the untouched old default both become the Amateur Cup.
UPDATE message_templates SET body = 'USASA Amateur Cup'
 WHERE kind = 'cup_roster' AND tier = 'default_cup' AND body = 'US Open Cup';
UPDATE cup_rosters SET cup = 'USASA Amateur Cup' WHERE cup = 'US Open Cup';

-- First-sheet defaults the owner gave 2026-10-11: Lighthouse home kit is
-- blue shirts / blue shorts / white socks, away is white shirts / blue
-- shorts / white socks; and the sheet's contact email is the club's
-- soccer@lighthouse1893.org, never a personal or footballhome address.
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Cup rosters', l, 'cup_roster', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('default_shirt_primary',  'First sheet default — shirt, primary',    'Blue',  902),
    ('default_shorts_primary', 'First sheet default — shorts, primary',   'Blue',  903),
    ('default_socks_primary',  'First sheet default — socks, primary',    'White', 904),
    ('default_shirt_alt',      'First sheet default — shirt, alternate',  'White', 905),
    ('default_shorts_alt',     'First sheet default — shorts, alternate', 'Blue',  906),
    ('default_socks_alt',      'First sheet default — socks, alternate',  'White', 907),
    ('default_coach_email',    'First sheet default — contact email (overrides the coach''s own)', 'soccer@lighthouse1893.org', 908)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'cup_roster' AND m.tier = v.t);
