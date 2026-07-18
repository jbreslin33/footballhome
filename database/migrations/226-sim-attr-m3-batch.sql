-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Migration 226: sim_attribute_registry M3 behavior attribute batch
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
--
-- Slice 31.3 (pulled ahead of behavior implementation): seeds the stable
-- attribute ids consumed by the M3 defender + attacker utility behaviors.
-- Registry-only; no runtime code reads these values yet, so determinism
-- goldens stay byte-identical.
--
-- ID assignments:
--   16 = technical.marking_technique
--   17 = technical.standing_tackle
--   18 = technical.interception
--   19 = technical.feint
--   20 = technical.first_time_pass
--   21 = mental.aggression
--   22 = mental.positioning_sense
--   23 = mental.composure
--   24 = mental.anticipation
--
-- Defaults are authored in profile seed/load code, not in this registry
-- table. DESIGN.md §25.2 recommends neutral 0.5 for most of this batch,
-- with composure at 0.6 and aggression at 0.4 when default profile values
-- are expanded.
--
-- Idempotent: ON CONFLICT (key) DO NOTHING makes reruns safe.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

BEGIN;

INSERT INTO sim_attribute_registry (id, key, category, weight, description) VALUES
    (16, 'technical.marking_technique', 'technical', 1.0,
     'M3 defender utility input for MarkOpponentBehavior and JockeyBehavior: quality of body shape, spacing, and shadowing while defending off the ball'),
    (17, 'technical.standing_tackle', 'technical', 1.0,
     'M3 defender utility input for commit-to-tackle decisions once the defender leaves jockey posture'),
    (18, 'technical.interception', 'technical', 1.0,
     'M3 defender utility input for reading and stepping into passes or loose-ball lanes'),
    (19, 'technical.feint', 'technical', 1.0,
     'M3 attacker utility input for Feint1v1Behavior: ability to sell and execute a lateral change of direction'),
    (20, 'technical.first_time_pass', 'technical', 1.0,
     'M3 attacker/support utility input reserved for one-touch pass decisions after the first 1v1 behavior set'),
    (21, 'mental.aggression', 'mental', 1.0,
     'M3 utility bias: higher values make defenders more likely to step from jockey posture into pressure or tackle choices'),
    (22, 'mental.positioning_sense', 'mental', 1.0,
     'M3 utility bias for goal-side defensive positioning, jockey spacing, and mark-shadowing decisions'),
    (23, 'mental.composure', 'mental', 1.0,
     'M3 utility bias: steadier decision-making under pressure for both defender jockeying and attacker feints'),
    (24, 'mental.anticipation', 'mental', 1.0,
     'M3 utility bias for early recognition of dribbles, passes, and off-ball movement cues')
ON CONFLICT (key) DO NOTHING;

-- Same guarded setval as other registry migrations: the sequence may be
-- absent on databases that went through the hand-managed-id migration path.
DO $$
DECLARE
    seq_name TEXT;
BEGIN
    seq_name := pg_get_serial_sequence('sim_attribute_registry', 'id');
    IF seq_name IS NOT NULL THEN
        PERFORM setval(seq_name,
                       GREATEST((SELECT MAX(id) FROM sim_attribute_registry), 1));
    END IF;
END $$;

-- Self-audit for the stable attribute IDs.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'technical.marking_technique' AND id = 16) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: technical.marking_technique is not at id=16';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'technical.standing_tackle' AND id = 17) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: technical.standing_tackle is not at id=17';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'technical.interception' AND id = 18) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: technical.interception is not at id=18';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'technical.feint' AND id = 19) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: technical.feint is not at id=19';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'technical.first_time_pass' AND id = 20) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: technical.first_time_pass is not at id=20';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'mental.aggression' AND id = 21) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: mental.aggression is not at id=21';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'mental.positioning_sense' AND id = 22) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: mental.positioning_sense is not at id=22';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'mental.composure' AND id = 23) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: mental.composure is not at id=23';
    END IF;
    IF NOT EXISTS (SELECT 1 FROM sim_attribute_registry WHERE key = 'mental.anticipation' AND id = 24) THEN
        RAISE EXCEPTION 'migration 226 post-check failed: mental.anticipation is not at id=24';
    END IF;
END $$;

COMMIT;

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- End of migration 226.
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━