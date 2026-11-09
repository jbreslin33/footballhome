-- 1199 (2026-11-09) — Tactics trainer step 1 (docs/tactics-trainer.md, game/DESIGN.md §8.165):
-- each outfield man says what he's doing out of possession, in the board's vocabulary.
--
-- The engine names what it runs by code (ai::Act, kActCodes in game/src/ai/Orders.hpp). This
-- table says which game_concepts row each code plays, so the trainer labels men with the same
-- concept id and title the 🎯 Tactics board uses for a job. Only what the engine actually does
-- is a row: there is no man-marking, cover-shadow or trap in the clean engine yet, so no label
-- claims one. New engine behaviour = a new code in kActCodes + a row here.
--
-- One-way: the engine reads this to label men. Nothing from tactic_plans reaches a PL side.

BEGIN;

CREATE TABLE IF NOT EXISTS game_engine_acts (
    code        text PRIMARY KEY,
    concept_id  smallint NOT NULL REFERENCES game_concepts(id),
    note        text NOT NULL
);
COMMENT ON TABLE game_engine_acts IS 'Tactics trainer (mig 1199): an engine behaviour code (ai::kActCodes) → the game concept it plays; fh-game labels each man out of possession with it. Wording lives in game_concepts.';

INSERT INTO game_engine_acts (code, concept_id, note) VALUES
    ('block_spot',    67,  'HoldBlockSpot: his block spot by role and the ball''s band (DFL, G5.21) — the compact block'),
    ('block_recover', 11,  'HoldBlockSpot with the spot 5 m+ goal-side of him (physics.trainer.recover_m): he closes it at the back pace first (G5.32)'),
    ('block_cover',   2,   'The deeper centre-back of the pair, behind the one who steps (G5.41)'),
    ('press_ball',    164, 'PressBall: the one man on their carrier, at the real stand-off distance (DFL, G5.25)'),
    ('chase_ball',    131, 'ChaseBall: the loose ball''s man — the race read''s first (G5.21)')
ON CONFLICT (code) DO UPDATE SET concept_id = EXCLUDED.concept_id, note = EXCLUDED.note;

-- The engine says "running" (wired) for the concepts it now labels.
UPDATE game_concepts SET status = 'wired' WHERE id IN (67, 11, 2, 164, 131) AND status <> 'wired';

COMMIT;
