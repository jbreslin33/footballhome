-- 1206 (2026-11-09) — Game G5.72 (game/DESIGN.md §8.173): the engine now marks, so the tactics
-- trainer labels it. ai::Act::Mark (kActCodes "block_mark"): a CB / FB / DM goal-side of the man in
-- his zone (DefendingBlock::assignMarks / MarkMan), fitted to the DFL nearest-defender tables
-- (game/scripts/benchmarks_tracking_markers.py). The BRAIN entry's `other` is the man he marks, so a
-- copied PL moment carries the job and its target.
--
-- Concept 18 (man-oriented marking) is the nearest row. The engine's marking is zonal with a man:
-- he takes whoever enters his zone and hands him on when he leaves it; he does not follow him
-- anywhere. Cover-shadow (27) is not engine behaviour yet, so it gets no row (mig 1199's rule).

BEGIN;

INSERT INTO game_engine_acts (code, concept_id, note) VALUES
    ('block_mark', 18, 'MarkMan: a CB / FB / DM goal-side of the man in his zone (radius and stand-off by that man''s metres off our goal, DFL-fitted, G5.72); hands him on when he leaves the zone')
ON CONFLICT (code) DO UPDATE SET concept_id = EXCLUDED.concept_id, note = EXCLUDED.note;

COMMIT;
