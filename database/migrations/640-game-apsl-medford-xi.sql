-- 640 (2026-10-22) — game: Lighthouse APSL lines up as it did in the last
-- game, at Medford Strikers (match 9330, 10/21).
--
-- James: "use our lineup from last game vs medford". Mig 636 seated the
-- RSVP-able APSL roster by each player's last-used position; this reseats
-- the team from that game's Game Center lineup exactly: its 11 starters
-- in the 4-3-3 (positions mapped below), then its bench, then its
-- alternates, then anyone else RSVP-able. Attributes + descriptions follow
-- the PERSON (snapshot → reseat → restore), so nothing James edited is
-- lost; newcomers get the mig-636 random draw. Then mig 639's marking
-- roles are re-derived: everyone outfield man-marks, the CB with the best
-- anticipation + decisions is the free +1. No names in this file.
--
-- Medford lineup (4-4-2 labels) → our 4-3-3 slot:
--   Goalkeeper → GK · Right Back → RB · Center Back / B → CB, CB ·
--   Left Back → LB · Defensive Midfielder / B → CM, CM · Striker B → the
--   third CM (the second striker drops in as the 10) · Right Midfielder →
--   RW · Striker → ST · Left Midfielder → LW.

DO $$
DECLARE
    tid INT := (SELECT id FROM game_demo_teams WHERE name = 'Lighthouse APSL');
    next_shirt INT := 11;
    r RECORD;
BEGIN
    IF tid IS NULL THEN RETURN; END IF;

    CREATE TEMP TABLE keep_attrs ON COMMIT DROP AS
    SELECT p.person_id, a.attribute, a.rating
      FROM game_demo_players p JOIN game_demo_player_attributes a USING (team_id, shirt)
     WHERE p.team_id = tid AND p.person_id IS NOT NULL;
    CREATE TEMP TABLE keep_desc ON COMMIT DROP AS
    SELECT person_id, description FROM game_demo_players
     WHERE team_id = tid AND person_id IS NOT NULL AND description IS NOT NULL;

    DELETE FROM game_demo_players WHERE team_id = tid;   -- cascades attrs + concepts

    CREATE TEMP TABLE xi ON COMMIT DROP AS
    SELECT DISTINCT ON (pl.person_id) pl.person_id, pos.name AS pos, ml.is_starter, ml.zone, ml.slot_number
      FROM match_lineups ml
      JOIN players pl ON pl.id = ml.player_id
      LEFT JOIN positions pos ON pos.id = ml.position_id
     WHERE ml.match_id = 9330 AND pl.person_id IS NOT NULL
     ORDER BY pl.person_id, ml.is_starter DESC;

    -- the starting XI, slot by slot
    INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, person_id, position)
    SELECT tid, m.slot, COALESCE(NULLIF(trim(pe.first_name || ' ' || pe.last_name), ''), 'Player ' || pe.id),
           640, pe.id, m.label
      FROM xi
      JOIN (VALUES ('Goalkeeper', 1, 'GK'), ('Right Back', 2, 'RB'), ('Center Back', 3, 'CB'),
                   ('Center Back B', 4, 'CB'), ('Left Back', 5, 'LB'), ('Defensive Midfielder', 6, 'CM'),
                   ('Defensive Midfielder B', 7, 'CM'), ('Striker B', 8, 'CM'), ('Right Midfielder', 9, 'RW'),
                   ('Striker', 10, 'ST'), ('Left Midfielder', 11, 'LW')) AS m(pos, slot, label) ON m.pos = xi.pos
      JOIN persons pe ON pe.id = xi.person_id
     WHERE xi.is_starter;

    -- bench, alternates, then the rest of the RSVP-able APSL roster
    FOR r IN
        SELECT person_id, 1 AS tier, slot_number FROM xi
         WHERE NOT is_starter AND zone = 'bench'
        UNION ALL
        SELECT person_id, 2, slot_number FROM xi WHERE NOT is_starter AND zone IS DISTINCT FROM 'bench'
        UNION ALL
        SELECT tp.person_id, 3, NULL FROM team_persons tp
         WHERE tp.team_id = 35 AND tp.removed_at IS NULL AND NOT COALESCE(tp.invite_only, false)
           AND tp.person_id NOT IN (SELECT person_id FROM xi)
        ORDER BY 2, 3 NULLS LAST, 1
    LOOP
        CONTINUE WHEN EXISTS (SELECT 1 FROM game_demo_players WHERE team_id = tid AND person_id = r.person_id);
        next_shirt := next_shirt + 1;
        INSERT INTO game_demo_players (team_id, shirt, name, max_speed_cms, person_id, position)
        SELECT tid, next_shirt, COALESCE(NULLIF(trim(pe.first_name || ' ' || pe.last_name), ''), 'Player ' || pe.id),
               640, pe.id, 'SUB'
          FROM persons pe WHERE pe.id = r.person_id;
    END LOOP;

    -- attributes + descriptions follow the person
    INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating)
    SELECT tid, p.shirt, k.attribute, k.rating
      FROM game_demo_players p JOIN keep_attrs k ON k.person_id = p.person_id
     WHERE p.team_id = tid;
    UPDATE game_demo_players p SET description = d.description
      FROM keep_desc d WHERE p.team_id = tid AND p.person_id = d.person_id;

    -- newcomers: the mig-636 draw (keepers 60-80 in goal, outfield 15-35)
    INSERT INTO game_demo_player_attributes (team_id, shirt, attribute, rating)
    SELECT p.team_id, p.shirt, a.code,
           CASE WHEN a.code = 'goalkeeping' AND p.position = 'GK' THEN 60 + abs(hashtext(p.team_id || ':' || p.person_id || ':' || a.code)) % 21
                WHEN a.code = 'goalkeeping'                       THEN 15 + abs(hashtext(p.team_id || ':' || p.person_id || ':' || a.code)) % 21
                ELSE 40 + abs(hashtext(p.team_id || ':' || p.person_id || ':' || a.code)) % 36 END
      FROM game_demo_players p CROSS JOIN game_attributes a
     WHERE p.team_id = tid
    ON CONFLICT (team_id, shirt, attribute) DO NOTHING;

    -- marking roles (mig 639): man-mark everywhere outfield…
    INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating)
    SELECT p.team_id, p.shirt, c.concept, 90
      FROM game_demo_players p CROSS JOIN (VALUES ('marking'), ('man-mark')) AS c(concept)
     WHERE p.team_id = tid AND p.position <> 'GK';
    -- …but the best-reading centre back is the free +1.
    INSERT INTO game_demo_player_concepts (team_id, shirt, concept, rating)
    SELECT s.team_id, s.shirt, v.concept, v.rating
      FROM (SELECT p.team_id, p.shirt
              FROM game_demo_players p
              LEFT JOIN game_demo_player_attributes a ON a.team_id = p.team_id AND a.shirt = p.shirt
                                                      AND a.attribute IN ('anticipation', 'decisions')
             WHERE p.team_id = tid AND p.position = 'CB'
             GROUP BY p.team_id, p.shirt
             ORDER BY COALESCE(sum(a.rating), 0) DESC, p.shirt
             LIMIT 1) s
     CROSS JOIN (VALUES ('marking', 0), ('man-mark', 0), ('cover', 95)) AS v(concept, rating)
    ON CONFLICT (team_id, shirt, concept) DO UPDATE SET rating = EXCLUDED.rating;
END $$;
