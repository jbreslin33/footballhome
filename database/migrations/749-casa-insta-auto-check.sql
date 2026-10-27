-- 749: CASA scores from Instagram, checked by the server on a schedule.
--
-- Owner 2026-10-27: "headless on a schedule" — Sun 6 PM, Sun 11:59 PM,
-- Mon 6 AM, Mon 12 PM, then 12 PM Tue–Sat (systemd/casa-insta-scores.timer).
-- scripts/casa-insta-scores.js reads the unscored games, opens each club's
-- Instagram in headless Chrome on the server (logged out — the grid and post
-- pages show without a login, no VPN), and has Claude read each post from the
-- game day through 3 days after.  One row per post read, so a post is never
-- read (or paid for) twice; a row with fixture_id is a score found for that
-- game, shown on #casa-scores next to the game.  SportsEngine stays the
-- source of truth — nothing here writes a score anywhere.
-- The manual path stays: "check all casa scores from insta" in the terminal
-- (.claude/skills/casa-insta-scores, Claude in Chrome).

CREATE TABLE IF NOT EXISTS casa_insta_runs (
    id             SERIAL PRIMARY KEY,
    started_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    finished_at    TIMESTAMPTZ,
    games_waiting  INTEGER NOT NULL DEFAULT 0,
    clubs_checked  INTEGER NOT NULL DEFAULT 0,
    posts_read     INTEGER NOT NULL DEFAULT 0,
    scores_found   INTEGER NOT NULL DEFAULT 0,
    problem        TEXT        -- a club page that showed no posts, an API failure …
);

CREATE TABLE IF NOT EXISTS casa_insta_posts (
    id          SERIAL PRIMARY KEY,
    post_url    TEXT NOT NULL UNIQUE,
    club_id     INTEGER REFERENCES clubs(id) ON DELETE SET NULL,
    handle      TEXT NOT NULL,
    posted_at   TIMESTAMPTZ,
    caption     TEXT,
    fixture_id  INTEGER REFERENCES league_fixtures(id) ON DELETE SET NULL,
    home_score  INTEGER,   -- in the fixture's home/away order, not the post's
    away_score  INTEGER,
    confidence  TEXT CHECK (confidence IN ('high', 'medium', 'low')),
    note        TEXT,
    run_id      INTEGER REFERENCES casa_insta_runs(id) ON DELETE SET NULL,
    read_at     TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (fixture_id IS NULL OR (home_score IS NOT NULL AND away_score IS NOT NULL))
);
CREATE INDEX IF NOT EXISTS casa_insta_posts_fixture ON casa_insta_posts (fixture_id) WHERE fixture_id IS NOT NULL;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side)
SELECT 'CASA', l, 'casa', t, NULL, b, o, true, true
  FROM (VALUES
    ('insta_found',  'CASA scores — a score read off a club''s Instagram ({handle} {home} {away} {when})', '📸 @{handle} posted {home} – {away} · {when}', 65),
    ('insta_auto',   'CASA scores — the server''s Instagram check ({when} {posts} {found})', 'Auto-check: last ran {when} · {posts} new posts read · {found} scores found. Runs Sun 6 PM & 11:59 PM, Mon 6 AM & noon, Tue–Sat noon.', 66),
    ('insta_problem','CASA scores — the last auto-check hit a problem ({problem})', '⚠ Last auto-check: {problem}', 67)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'casa' AND m.tier = v.t);

-- The old hint said the home network is blocked — the server reaches
-- Instagram fine logged out; the VPN is only for the manual Chrome check.
UPDATE message_templates
   SET body = 'Opening several tabs needs pop-ups allowed for this site (one time). The server checks these pages on its own (below); to look yourself from the terminal: "check all casa scores from insta".'
 WHERE kind = 'casa' AND tier = 'insta_popups' AND body LIKE '%blocked on the home network%';
