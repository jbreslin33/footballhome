-- 653 (2026-10-23) — game: the second taxonomy — TECHNIQUES — and the
-- knowledge triple per player (game/DESIGN.md §8.35). Schema only: the
-- technique tree and the research merge are seeded after James reviews them.
--
-- James: "what about player abilities for the concepts perception and
-- execution and then the physical skills like 1st touch 2nd touch,
-- dribbling various dribbling moves all the types of passes and distances.
-- unmarking techniques. combo play". DESIGN §5.2's knowledge triple:
--   perceive  — does he SEE the cue?        game_demo_player_concepts.perception
--   decide    — does he know the ANSWER?    game_demo_player_concepts.rating
--   execute   — can he PULL IT OFF?         the techniques the concept needs
--                                           (game_concept_techniques) rated per
--                                           player (game_demo_player_techniques),
--                                           plus physical / mental attributes.
-- Combination play stays in the concept tree (a group decision); what it
-- asks of each player is techniques.

CREATE TABLE IF NOT EXISTS game_techniques (
    id          SMALLINT PRIMARY KEY CHECK (id BETWEEN 0 AND 999),   -- stable, append-only
    code        TEXT NOT NULL UNIQUE,
    parent_id   SMALLINT REFERENCES game_techniques(id),
    node        TEXT NOT NULL CHECK (node IN ('family', 'group', 'technique')),
    title       TEXT NOT NULL,
    how         TEXT NOT NULL,          -- cue → execution, in coaching words
    taught_from TEXT CHECK (taught_from IN ('u10', 'u14', 'amateur', 'semipro', 'pro', 'world')),
    status      TEXT NOT NULL DEFAULT 'teaching' CHECK (status IN ('wired', 'queued', 'teaching')),
    sort_order  SMALLINT NOT NULL DEFAULT 0,
    CHECK (node = 'family' OR parent_id IS NOT NULL),
    CHECK (node = 'technique' OR taught_from IS NULL)
);
COMMENT ON TABLE game_techniques IS 'Techniques (player actions) as a tree: family → group → technique (mig 653). Rated per player; a concept needs some to be executed.';
COMMENT ON COLUMN game_techniques.taught_from IS 'Lowest level band introduced (federation ages) — NULL = not placed yet.';
COMMENT ON COLUMN game_techniques.status IS 'wired = the engine executes it with its own numbers; queued = planned; teaching = curriculum only.';

CREATE TABLE IF NOT EXISTS game_technique_sources (
    technique_id SMALLINT NOT NULL REFERENCES game_techniques(id),
    source_id    INTEGER NOT NULL REFERENCES game_sources(id),
    citation     TEXT NOT NULL,
    local_name   TEXT,
    verified     BOOLEAN NOT NULL DEFAULT true,
    PRIMARY KEY (technique_id, source_id)
);

CREATE TABLE IF NOT EXISTS game_concept_techniques (
    concept_id   SMALLINT NOT NULL REFERENCES game_concepts(id),
    technique_id SMALLINT NOT NULL REFERENCES game_techniques(id),
    PRIMARY KEY (concept_id, technique_id)
);
COMMENT ON TABLE game_concept_techniques IS 'What a concept needs to be EXECUTED (mig 653): over-top → the lofted long pass; blind-side run → the curved run and the spin.';

CREATE TABLE IF NOT EXISTS game_demo_player_techniques (
    team_id      INTEGER NOT NULL,
    shirt        INTEGER NOT NULL,
    technique_id SMALLINT NOT NULL REFERENCES game_techniques(id),
    rating       SMALLINT NOT NULL CHECK (rating BETWEEN 0 AND 100),
    PRIMARY KEY (team_id, shirt, technique_id),
    FOREIGN KEY (team_id, shirt) REFERENCES game_demo_players(team_id, shirt) ON DELETE CASCADE
);
COMMENT ON TABLE game_demo_player_techniques IS 'A player''s rating per technique (mig 653); absent = his band''s default.';

-- Perceive vs decide, per player per concept.
ALTER TABLE game_demo_player_concepts
    ADD COLUMN IF NOT EXISTS perception SMALLINT CHECK (perception BETWEEN 0 AND 100);
COMMENT ON COLUMN game_demo_player_concepts.rating IS 'DECIDE: does he know the answer (0-100) — his ability on this concept (mig 652).';
COMMENT ON COLUMN game_demo_player_concepts.perception IS 'PERCEIVE: does he see the cue (0-100); NULL = same as his anticipation / band (mig 653).';

-- Attributes grow by rows too; the editor lists every row, the engine
-- plays the wired ones.
ALTER TABLE game_attributes
    ADD COLUMN IF NOT EXISTS status TEXT NOT NULL DEFAULT 'wired'
        CHECK (status IN ('wired', 'queued', 'teaching'));
COMMENT ON COLUMN game_attributes.status IS 'wired = the engine uses it (mig 636 eight); queued / teaching = rated and coached, not yet played (mig 653).';
