-- 1891 (2026-11-25): the resolver, and the first machine that REPLACES the job's orders — recover.
--
-- docs/taxonomy-one-system.md "Player brain as parallel machines": awake machines propose, a resolver
-- combines them — complementing proposals merge, conflicting ones go by machine_order. Recover is the
-- first to take his spot outright: with his place 5 m+ goal-side of him he goes straight back to it,
-- and pressing distance's bend toward his man is dropped until he is back. With no dial rows the
-- bend never fires, so the goldens are unchanged.
INSERT INTO game_engine_behaviours (code, file, line, tag, who, what, status, concept_id, other_concepts, suggested, confidence, is_read, in_sim)
SELECT v.code, 'game/src/ai/concepts/Machines.cpp', 1, 'concept machines 11/25', 'individual', v.what, 'concept',
       (SELECT id FROM game_concepts WHERE name = v.concept), v.other, NULL, 'high', true, true
  FROM (VALUES
    ('machine_resolver', 'recover', 'pressing-distance',
     'The resolver: of his awake machines that take his spot, the highest in machine_order drives; a lower machine''s bend of that spot is dropped (they fight), a bend of the job''s own target still applies (they complement).'),
    ('recover_takes_his_spot', 'recover', '',
     'His recover machine REPLACES the hold job''s orders: line broken behind him, he goes straight back to his place in the shape, and pressing distance does not pull him off it to his man until he is back.')
  ) AS v(code, concept, other, what)
ON CONFLICT (code) DO NOTHING;
UPDATE game_engine_terms SET note = 'ai/concepts/Machines — MachineId::Recover · TAKES HIS SPOT (recoverTo, mig 1891)'
 WHERE kind = 'machine' AND code = 'recover';
