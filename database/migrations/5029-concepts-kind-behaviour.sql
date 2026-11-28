-- 5029 (2026-11-27): game_concepts.kind 'skill' → 'behaviour'. A concept of this kind is a thing a player
-- knows to do in a moment (a decision or movement), not a technique — "skill" read as technique.
BEGIN;
ALTER TABLE game_concepts DROP CONSTRAINT game_concepts_kind_check;
UPDATE game_concepts SET kind = 'behaviour' WHERE kind = 'skill';
ALTER TABLE game_concepts ALTER COLUMN kind SET DEFAULT 'behaviour';
ALTER TABLE game_concepts ADD CONSTRAINT game_concepts_kind_check CHECK (kind IN ('behaviour', 'style', 'call'));
COMMIT;
