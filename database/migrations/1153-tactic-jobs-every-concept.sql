-- 1153 (2026-11-06): Tactics 🧠 — every game concept for the moment is a job.
--
-- Owner 11/6: "we should have all 'game' tactics in the 'tactic' drop down
-- for that phase. in this case defensive phase."  Until now the dropdown
-- held six hand-picked jobs (mark, cover-shadow, hold-between, straddle,
-- deter, read).  Now every individual / group / team concept of the
-- defending moments (out_of_possession, to_defend) is a tactic_job_kinds
-- row, so the job a coach picks IS the game concept the AI plays — same
-- row, same cue words.  The dropdown shows the plan's moment only.
--
-- Where the man is DRAWN comes from the kind's rule (tactic_job_rules) —
-- the placement TacticGeometry knows how to compute.  A concept with no
-- spot of its own yet ('home') keeps his formation spot and carries the
-- concept as his instruction; its own geometry is the game's to write
-- (game/DESIGN.md §8.137) and lands as a rule change, not a new job.
-- Keeper concepts are left out: the keeper's spot is the block's gk_y.

CREATE TABLE IF NOT EXISTS tactic_job_rules (
    code       text PRIMARY KEY,
    label      text NOT NULL,
    sort_order smallint NOT NULL DEFAULT 0
);

INSERT INTO tactic_job_rules (code, label, sort_order) VALUES
    ('mark',         'Goal-side of his man (stance: goal-side or intercept)', 1),
    ('press',        'Tight on his man, goal-side, 1 m',                      2),
    ('cover_shadow', 'On the line from the ball to the men he shadows',       3),
    ('lane',         'In the passing lane(s) from the ball',                  4),
    ('hold_between', 'In the gap between two men, goal-side',                 5),
    ('straddle',     'Bookends one man with a teammate',                      6),
    ('home',         'His formation spot (concept carried as instruction)',   7)
ON CONFLICT (code) DO NOTHING;

ALTER TABLE tactic_job_kinds ADD COLUMN IF NOT EXISTS rule text REFERENCES tactic_job_rules(code);
UPDATE tactic_job_kinds SET rule = CASE code WHEN 'deter' THEN 'lane' WHEN 'read' THEN 'lane' ELSE code END WHERE rule IS NULL;
ALTER TABLE tactic_job_kinds ALTER COLUMN rule SET NOT NULL;
-- A 'home' job names nobody.
ALTER TABLE tactic_job_kinds ALTER COLUMN target_a_label DROP NOT NULL;

-- Each concept's rule.  Defaults per rule below; the six existing kinds keep
-- their own rows.
WITH rule_of(concept_id, rule) AS (VALUES
    -- out_of_possession · group
    (2,'home'),(12,'press'),(38,'press'),(45,'press'),(46,'press'),(47,'press'),(102,'press'),
    (104,'cover_shadow'),(117,'mark'),(118,'home'),(119,'hold_between'),(125,'mark'),(166,'cover_shadow'),
    -- out_of_possession · individual
    (1,'mark'),(10,'press'),(21,'press'),(22,'press'),(26,'home'),(48,'press'),(63,'mark'),(64,'press'),
    (101,'press'),(103,'cover_shadow'),(107,'mark'),(108,'cover_shadow'),(120,'mark'),(121,'mark'),
    (123,'mark'),(124,'mark'),(126,'home'),(127,'press'),(128,'home'),(129,'home'),(149,'home'),
    (150,'mark'),(154,'mark'),(155,'press'),(156,'mark'),(157,'press'),(158,'mark'),(160,'mark'),
    (162,'lane'),(163,'cover_shadow'),(164,'cover_shadow'),(167,'cover_shadow'),(168,'mark'),
    (169,'cover_shadow'),(170,'mark'),(171,'home'),(172,'home'),(178,'press'),(179,'press'),
    -- out_of_possession · team
    (9,'home'),(15,'home'),(17,'home'),(28,'home'),(36,'home'),(44,'home'),(67,'home'),(68,'home'),
    (71,'home'),(105,'home'),(106,'press'),(109,'home'),(110,'home'),(111,'home'),(112,'press'),
    (113,'home'),(114,'home'),(115,'home'),(116,'home'),(122,'mark'),(165,'home'),
    -- to_defend
    (0,'press'),(11,'mark'),(16,'press'),(49,'home'),(50,'mark'),(51,'home'),(130,'home'),
    (131,'press'),(132,'home'),(133,'hold_between'),(134,'press')
), defaults(rule, target_a_label, target_b_label, dist_m, press_m, multi_a, lane_t) AS (VALUES
    ('mark',         'mark',   NULL,         2.0, NULL::numeric, false, NULL::numeric),
    ('press',        'press',  NULL,         1.0, NULL,          false, NULL),
    ('cover_shadow', 'shadow', 'then press', 4.0, 1.5,           true,  NULL),
    ('lane',         'cut',    NULL,         0.0, NULL,          true,  0.55),
    ('hold_between', 'between','and',        3.0, NULL,          false, NULL),
    ('home',         NULL,     NULL,         0.0, NULL,          false, NULL)
)
INSERT INTO tactic_job_kinds (code, concept_id, label, target_a_label, target_b_label, dist_m, press_m, multi_a, lane_t, rule, sort_order)
SELECT c.name, c.id, c.title, d.target_a_label, d.target_b_label, d.dist_m, d.press_m, d.multi_a, d.lane_t, r.rule,
       100 + (CASE c.family WHEN 'individual' THEN 0 WHEN 'group' THEN 300 ELSE 600 END) + c.id
  FROM rule_of r
  JOIN game_concepts c ON c.id = r.concept_id
  JOIN defaults d ON d.rule = r.rule
 WHERE c.moment IN ('out_of_possession', 'to_defend')
   AND c.family <> 'keeper'
   AND NOT EXISTS (SELECT 1 FROM tactic_job_kinds k WHERE k.concept_id = c.id OR k.code = c.name);

-- Play off for the long ball: stand well off him.
UPDATE tactic_job_kinds SET dist_m = 6.0 WHERE code = (SELECT name FROM game_concepts WHERE id = 170);

-- Dropdown group headings (client copy).
INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Tactics', v.label, 'tactics', v.tier, NULL, v.body, v.sort_order, true, true, false
  FROM (VALUES
    ('Job group — individual', 'fam_individual', 'Individual', 1240),
    ('Job group — group',      'fam_group',      'Group',      1241),
    ('Job group — team',       'fam_team',       'Team',       1242),
    ('Job — no spot yet',      'home_note',      'stands in his formation spot — the concept is his instruction', 1243)
  ) AS v(label, tier, body, sort_order)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'tactics' AND m.tier = v.tier);
