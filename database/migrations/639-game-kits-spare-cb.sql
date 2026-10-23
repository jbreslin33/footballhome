-- 639 (2026-10-22) — game: team kits + per-player knowledge; Lighthouse
-- man-marks with a spare centre back (game/DESIGN.md §8.27).
--
-- James: "make lighthouse man mark with + 1 and -1 on center backs. make
-- lh white socks, blue shorts blue shirts. ukies black socks white shorts
-- and white shirts".
--
-- 1. Kits live on the team row (shirt / shorts / socks / trim, '#rrggbb');
--    the daemon sends them in the TEAMS frame. NULL = the client's default.
-- 2. game_demo_player_concepts: per-player knowledge overrides by concept
--    NAME (game/CONCEPTS.md / core::kConceptNames — names survive bit
--    growth), applied AFTER the team's style preset, so a role beats the
--    team identity ("Lighthouse" preset + "you are the spare").
-- 3. Lighthouse APSL man-marks [Bielsa]: every outfield player marking 90 +
--    man-mark 90 — except ONE centre back, the +1: marking 0 / man-mark 0 /
--    cover 95, the free man behind the duels (the engine's marking hand-out
--    skips non-markers, so nobody's man is "spent" on him). Against the
--    Ukies' lone 9 the other CB takes the striker: +1 at the back. Up top
--    our three forwards meet their back four: -1 there by construction.
--    The spare = the CB with the best anticipation + decisions (reads the
--    game), James can move it in the editor's KNOWLEDGE tab.

ALTER TABLE game_demo_teams ADD COLUMN IF NOT EXISTS kit_shirt  TEXT CHECK (kit_shirt  ~ '^#[0-9a-fA-F]{6}$');
ALTER TABLE game_demo_teams ADD COLUMN IF NOT EXISTS kit_shorts TEXT CHECK (kit_shorts ~ '^#[0-9a-fA-F]{6}$');
ALTER TABLE game_demo_teams ADD COLUMN IF NOT EXISTS kit_socks  TEXT CHECK (kit_socks  ~ '^#[0-9a-fA-F]{6}$');
ALTER TABLE game_demo_teams ADD COLUMN IF NOT EXISTS kit_trim   TEXT CHECK (kit_trim   ~ '^#[0-9a-fA-F]{6}$');

UPDATE game_demo_teams SET kit_shirt = '#14326e', kit_shorts = '#14326e', kit_socks = '#f4f6fb', kit_trim = '#ffcc00'
 WHERE name = 'Lighthouse APSL';
UPDATE game_demo_teams SET kit_shirt = '#f4f6fb', kit_shorts = '#f4f6fb', kit_socks = '#111111', kit_trim = '#111111'
 WHERE name = 'Ukrainian Nationals';

CREATE TABLE IF NOT EXISTS game_demo_player_concepts (
    team_id  INT  NOT NULL,
    shirt    INT  NOT NULL,
    concept  TEXT NOT NULL,          -- core::kConceptNames, e.g. 'man-mark'
    rating   SMALLINT NOT NULL CHECK (rating BETWEEN 0 AND 100),
    PRIMARY KEY (team_id, shirt, concept),
    FOREIGN KEY (team_id, shirt) REFERENCES game_demo_players(team_id, shirt) ON DELETE CASCADE
);
COMMENT ON TABLE game_demo_player_concepts IS 'Per-player knowledge overrides by concept name (mig 639), applied after the team style preset.';

-- Lighthouse APSL: man-mark everywhere outfield…
INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating)
SELECT p.team_id, p.shirt, c.concept, 90
  FROM game_demo_players p
  JOIN game_demo_teams t ON t.id = p.team_id AND t.name = 'Lighthouse APSL'
 CROSS JOIN (VALUES ('marking'), ('man-mark')) AS c(concept)
 WHERE p.position <> 'GK'
ON CONFLICT (team_id, shirt, concept) DO UPDATE SET rating = EXCLUDED.rating;

-- …but one centre back is the +1: free, covering.
WITH spare AS (
    SELECT p.team_id, p.shirt
      FROM game_demo_players p
      JOIN game_demo_teams t ON t.id = p.team_id AND t.name = 'Lighthouse APSL'
      LEFT JOIN game_demo_player_attributes a ON a.team_id = p.team_id AND a.shirt = p.shirt
                                              AND a.attribute IN ('anticipation', 'decisions')
     WHERE p.position = 'CB'
     GROUP BY p.team_id, p.shirt
     ORDER BY COALESCE(sum(a.rating), 0) DESC, p.shirt
     LIMIT 1
)
INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating)
SELECT s.team_id, s.shirt, v.concept, v.rating
  FROM spare s CROSS JOIN (VALUES ('marking', 0), ('man-mark', 0), ('cover', 95)) AS v(concept, rating)
ON CONFLICT (team_id, shirt, concept) DO UPDATE SET rating = EXCLUDED.rating;
