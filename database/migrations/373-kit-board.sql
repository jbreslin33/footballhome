-- 373: Uniform numbers + kit handed out (the #kit board).
--
-- Why (owner, 2026-09-18): "We need a page for uniform number assignment and
-- to check off if the player received training shirt and training pinnie …
-- and later possibly issuing of other equipment."
--
-- Numbers already have a home: team_persons.jersey_number (per team
-- membership, so a player on APSL and the Reserves can wear different
-- numbers). It has never been written — 0 of 2,728 rows — so the only thing
-- missing is the rule that two active players on one team can't share one.
--
-- Kit is per person, not per team: a player gets one training shirt whichever
-- squads they are on. What can be handed out is a lookup table, so "other
-- equipment later" is a new kit_items row by migration and no screen change.
-- A row in person_kit_issues means "has it"; un-ticking deletes the row.

BEGIN;

CREATE UNIQUE INDEX IF NOT EXISTS team_persons_team_jersey_active_key
    ON team_persons (team_id, jersey_number)
    WHERE removed_at IS NULL AND jersey_number IS NOT NULL;

CREATE TABLE IF NOT EXISTS kit_items (
    id         serial PRIMARY KEY,
    code       varchar(40)  NOT NULL UNIQUE,
    label      varchar(80)  NOT NULL,
    icon       text,
    sort_order integer      NOT NULL DEFAULT 0,
    is_active  boolean      NOT NULL DEFAULT true
);

COMMENT ON TABLE kit_items IS
    'Things the club hands to a player (training shirt, pinnie, …). Columns of the #kit board; add one by migration.';

INSERT INTO kit_items (code, label, icon, sort_order) VALUES
    ('training_shirt',  'Training shirt',  '👕', 10),
    ('training_pinnie', 'Training pinnie', '🎽', 20)
ON CONFLICT (code) DO NOTHING;

CREATE TABLE IF NOT EXISTS person_kit_issues (
    id                bigserial PRIMARY KEY,
    person_id         integer NOT NULL REFERENCES persons(id)   ON DELETE CASCADE,
    kit_item_id       integer NOT NULL REFERENCES kit_items(id) ON DELETE RESTRICT,
    issued_at         timestamptz NOT NULL DEFAULT now(),
    issued_by_user_id integer REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE (person_id, kit_item_id)
);

COMMENT ON TABLE person_kit_issues IS
    'One row = this person has received this kit item. Per person, not per team.';

CREATE INDEX IF NOT EXISTS idx_person_kit_issues_item ON person_kit_issues (kit_item_id);

COMMIT;
