-- 762 (2026-10-27) — game: every top-level game model states every concept;
-- "Semi Pro Standard" (the Ukies' 4-2-3-1); the taxonomy loses core/style
-- (game/DESIGN.md §8.74, G4.76).
--
-- James 10/27: "the model should show ALL football concepts and if its not
-- included at all then it would be set to 0 right? this is easier to keep
-- track right?" / "lets really define what the football taxonomy is and then
-- what a game model is and how it will be stored in db normalized" / "lets
-- make a game model though called "Semi Pro Standard" this is the 4231 the
-- ukies are running. have ukies use it verbatim but of course its their own
-- model ... make the ukies inherit (in db like you said) all of the Semi pro
-- standard"
--
-- The rule from here on:
--   * game_concepts is the dictionary — facts about football only. Whether
--     a coach asks for a concept is the coach's call, so kind (core/style)
--     goes: it was a demand pretending to be a fact, applied by C++ code
--     (core 100 / style 0) that nobody could see.
--   * A top-level model (no parent) has a row for EVERY concept — enforced
--     at commit by the trigger below, so a migration adding a concept must
--     say what each top-level model asks for it.
--   * A child model holds only its differences; no row = its parent's value.
--   * A team with no coach's identity plays "Curriculum": every concept the
--     club teaches, nothing chosen (exactly the old code default).
-- Nothing changes on the pitch: every row written here is the value the
-- code used to make up.

BEGIN;

-- ── Semi Pro Standard: the Ukies' model today, flattened ────────────────
INSERT INTO game_models (name, kind, parent_id, formation_code, note, sort_order)
VALUES ('Semi Pro Standard', 'school', NULL, '4-2-3-1',
        'The standard semi-pro 4-2-3-1 the Ukrainian Nationals run: the U.S. Soccer U17+ principles plus a semi-pro line step, every concept stated (James 10/27).',
        49)
ON CONFLICT (name) DO NOTHING;

INSERT INTO game_models (name, kind, parent_id, formation_code, note, sort_order)
VALUES ('Curriculum', 'school', NULL, NULL,
        'No coach''s identity: every concept the club teaches asked in full, nothing chosen. Teams with no game model of their own play this.',
        48)
ON CONFLICT (name) DO NOTHING;

-- Semi Pro Standard = Ukrainian Nationals resolved: its own row, else
-- U.S. Soccer U17+, else the old default.
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT (SELECT id FROM game_models WHERE name = 'Semi Pro Standard'), c.id,
       COALESCE(u.demand, f.demand, CASE WHEN c.kind = 'style' THEN 0 ELSE 100 END),
       COALESCE(u.citation, f.citation,
                CASE WHEN c.kind = 'style' THEN 'Not asked (was the code default for a style concept).'
                     ELSE 'Asked in full (was the code default for a core concept).' END)
  FROM game_concepts c
  LEFT JOIN game_model_concepts u ON u.concept_id = c.id
        AND u.model_id = (SELECT id FROM game_models WHERE name = 'Ukrainian Nationals')
  LEFT JOIN game_model_concepts f ON f.concept_id = c.id
        AND f.model_id = (SELECT id FROM game_models WHERE name = 'U.S. Soccer U17+')
ON CONFLICT (model_id, concept_id) DO NOTHING;

-- The Ukies: their own model, everything inherited from Semi Pro Standard.
UPDATE game_models
   SET parent_id = (SELECT id FROM game_models WHERE name = 'Semi Pro Standard'),
       note = 'Ukrainian Nationals: Semi Pro Standard, verbatim for now — their own changes go here.'
 WHERE name = 'Ukrainian Nationals';
DELETE FROM game_model_concepts
 WHERE model_id = (SELECT id FROM game_models WHERE name = 'Ukrainian Nationals');

UPDATE game_demo_teams SET game_model = 'Curriculum' WHERE game_model IS NULL;
ALTER TABLE game_demo_teams ALTER COLUMN game_model SET NOT NULL;

-- ── Every top-level model states every concept ───────────────────────────
INSERT INTO game_model_concepts (model_id, concept_id, demand, citation)
SELECT m.id, c.id,
       CASE WHEN c.kind = 'style' THEN 0 ELSE 100 END,
       CASE WHEN c.kind = 'style' THEN 'Not asked (was the code default for a style concept).'
            ELSE 'Asked in full (was the code default for a core concept).' END
  FROM game_models m CROSS JOIN game_concepts c
 WHERE m.parent_id IS NULL
ON CONFLICT (model_id, concept_id) DO NOTHING;

-- …and the three rules by third (G4.68), 100 = the old code default.
INSERT INTO game_model_ladder (model_id, zone, rung, weight, note)
SELECT m.id, z, r, 100, 'Even (was the code default).'
  FROM game_models m
 CROSS JOIN unnest(ARRAY['own', 'middle', 'their']) z
 CROSS JOIN unnest(ARRAY['intercept', 'no_turn', 'contain']) r
 WHERE m.parent_id IS NULL
ON CONFLICT (model_id, zone, rung) DO NOTHING;

-- ── The dictionary is facts only ─────────────────────────────────────────
ALTER TABLE game_concepts DROP COLUMN kind;

-- ── Enforced at commit ───────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fh_game_models_complete() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE missing text;
BEGIN
    SELECT string_agg(m.name || ' / ' || c.name, ', ') INTO missing
      FROM game_models m CROSS JOIN game_concepts c
     WHERE m.parent_id IS NULL
       AND NOT EXISTS (SELECT 1 FROM game_model_concepts mc
                        WHERE mc.model_id = m.id AND mc.concept_id = c.id);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'every top-level game model must state every concept; missing: %', missing;
    END IF;
    SELECT string_agg(m.name || ' / ' || z || ' ' || r, ', ') INTO missing
      FROM game_models m
     CROSS JOIN unnest(ARRAY['own', 'middle', 'their']) z
     CROSS JOIN unnest(ARRAY['intercept', 'no_turn', 'contain']) r
     WHERE m.parent_id IS NULL
       AND NOT EXISTS (SELECT 1 FROM game_model_ladder l
                        WHERE l.model_id = m.id AND l.zone = z AND l.rung = r);
    IF missing IS NOT NULL THEN
        RAISE EXCEPTION 'every top-level game model must state its three rules by third; missing: %', missing;
    END IF;
    RETURN NULL;
END $$;

CREATE CONSTRAINT TRIGGER game_concepts_models_complete
    AFTER INSERT ON game_concepts DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fh_game_models_complete();
CREATE CONSTRAINT TRIGGER game_models_complete
    AFTER INSERT OR UPDATE OF parent_id ON game_models DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fh_game_models_complete();
CREATE CONSTRAINT TRIGGER game_model_concepts_complete
    AFTER DELETE OR UPDATE OF model_id, concept_id ON game_model_concepts DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fh_game_models_complete();
CREATE CONSTRAINT TRIGGER game_model_ladder_complete
    AFTER DELETE OR UPDATE OF model_id, zone, rung ON game_model_ladder DEFERRABLE INITIALLY DEFERRED
    FOR EACH ROW EXECUTE FUNCTION fh_game_models_complete();

COMMIT;
