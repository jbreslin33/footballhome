-- 1129 (2026-11-06) — Their build-out from a goal kick, per formation.
--
-- Owner: "for opp buildout their cbs would be in box next to keeper check
-- what is normally done at pro level. full backs would be wider."
--
-- What pro teams do since the 2019 Law 16 change (a goal kick is in play
-- once kicked, so it can be received INSIDE the penalty area):
--   * centre-backs split to the sides of the box, inside it, either side
--     of the keeper ("centre-backs dropping to the sides of the box while
--     full-backs move higher and wide, hugging the touchline")
--     [sportskeeda: The New Goal Kick rule change: A Primer;
--      tactico.pages.dev/formations/4-3-3: "a centre-back who splits wide
--      inside the edge of the penalty area"]
--   * the 6 drops in front of / between them to make a three
--     [footballgpt 4-3-3 guide; FIFA Training Centre, Building from goal
--      kicks: the keeper is the extra man against a high press]
--   * full-backs high and wide on the touchline; wingers and the 9 pin our
--     back line.
-- Placements below are [FH] from those descriptions (no tracking-data cut
-- yet — the game session holds the DFL tracking set if we want one).
--
-- Coordinates 0–100 from OUR view (their goal at the top, y 100); their
-- right side is on our left.  Penalty area: x 20.4–79.6, y 84.3–100.
--
-- A new plan for out_of_possession starts its "their GK" state from this
-- shape when the opponent formation has one (TacticPlans::create); the
-- two plans that exist get it on their root states now.

CREATE TABLE IF NOT EXISTS tactic_buildout_shapes (
    formation_id  integer  NOT NULL REFERENCES formations(id) ON DELETE CASCADE,
    number        smallint NOT NULL CHECK (number BETWEEN 1 AND 11),
    x             numeric(5,2) NOT NULL CHECK (x BETWEEN 0 AND 100),
    y             numeric(5,2) NOT NULL CHECK (y BETWEEN 0 AND 100),
    PRIMARY KEY (formation_id, number)
);

INSERT INTO tactic_buildout_shapes (formation_id, number, x, y)
SELECT f.id, v.n, v.x, v.y FROM formations f, (VALUES
    (1, 50, 97),   -- keeper on the ball, goal area
    (4, 27, 90),   -- right CB: left side of the box (our view), inside it
    (5, 73, 90),   -- left CB: right side of the box
    (6, 50, 80),   -- pivot drops in front, at the D
    (2,  6, 72),   -- right back: high on the touchline
    (3, 94, 72),   -- left back
    (8, 35, 66),   -- eights in the half-spaces
    (10, 65, 66),
    (7,  7, 54),   -- wingers high and wide, pinning
    (11, 93, 54),
    (9, 50, 54)    -- 9 on our last line
  ) AS v(n, x, y)
 WHERE f.code = '4-3-3'
ON CONFLICT (formation_id, number) DO NOTHING;

-- Existing plans: the root (their GK on the ball) takes the shape.
DELETE FROM tactic_state_opponents o
 USING tactic_states s, tactic_plans p
 WHERE o.state_id = s.id AND s.plan_id = p.id AND s.parent_state_id IS NULL
   AND p.moment = 'out_of_possession'
   AND EXISTS (SELECT 1 FROM tactic_buildout_shapes b WHERE b.formation_id = p.opponent_formation_id);
INSERT INTO tactic_state_opponents (state_id, number, x, y)
SELECT s.id, b.number, b.x, b.y
  FROM tactic_states s JOIN tactic_plans p ON p.id = s.plan_id
  JOIN tactic_buildout_shapes b ON b.formation_id = p.opponent_formation_id
 WHERE s.parent_state_id IS NULL AND p.moment = 'out_of_possession'
ON CONFLICT DO NOTHING;
