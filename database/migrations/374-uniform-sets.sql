-- 374: A uniform number belongs to the uniform, not the team.
--
-- Why (owner, 2026-09-18): "the kits are same for liga 1 and apsl so if a
-- player has one on one it counts for all." Migration 373 kept numbers on
-- team_persons — one per team membership — which let a man on APSL and the
-- Reserves be #9 on one and #14 on the other, and let two men on different
-- squads both be #9, in the same shirt. Kit ticks were already per person.
--
-- A uniform_set is a set of shirts; teams that wear the same one point at the
-- same row. A player has ONE number per set, unique within it. The three
-- men's squads (APSL, APSL Reserves, Liga 1) share a set; every other board
-- team gets its own until someone says they share too — re-point
-- teams.uniform_set_id by migration.
--
-- team_persons.jersey_number goes back to being unwritten; its one value
-- moves across and the 373 index is dropped.

BEGIN;

CREATE TABLE IF NOT EXISTS uniform_sets (
    id   serial PRIMARY KEY,
    name varchar(80) NOT NULL UNIQUE
);
COMMENT ON TABLE uniform_sets IS
    'A set of match shirts. Teams wearing the same shirts share a row, and so share one pool of numbers.';

ALTER TABLE teams
    ADD COLUMN IF NOT EXISTS uniform_set_id integer REFERENCES uniform_sets(id) ON DELETE SET NULL;

INSERT INTO uniform_sets (name) VALUES ('Mens') ON CONFLICT (name) DO NOTHING;
UPDATE teams SET uniform_set_id = (SELECT id FROM uniform_sets WHERE name = 'Mens')
 WHERE id IN (35, 938, 120) AND uniform_set_id IS NULL;

-- Every other board team: a set of its own, named after the team.
INSERT INTO uniform_sets (name)
SELECT t.name FROM teams t
 WHERE t.is_active AND t.board_sort_order IS NOT NULL AND t.uniform_set_id IS NULL
ON CONFLICT (name) DO NOTHING;
UPDATE teams t SET uniform_set_id = us.id
  FROM uniform_sets us
 WHERE us.name = t.name AND t.is_active AND t.board_sort_order IS NOT NULL
   AND t.uniform_set_id IS NULL;

CREATE TABLE IF NOT EXISTS person_uniform_numbers (
    id                  bigserial PRIMARY KEY,
    uniform_set_id      integer NOT NULL REFERENCES uniform_sets(id) ON DELETE CASCADE,
    person_id           integer NOT NULL REFERENCES persons(id)      ON DELETE CASCADE,
    jersey_number       varchar(3) NOT NULL CHECK (jersey_number ~ '^[0-9]{1,3}$'),
    assigned_at         timestamptz NOT NULL DEFAULT now(),
    assigned_by_user_id integer REFERENCES users(id) ON DELETE SET NULL,
    UNIQUE (uniform_set_id, person_id),
    UNIQUE (uniform_set_id, jersey_number)
);
COMMENT ON TABLE person_uniform_numbers IS
    'The number a person wears in a uniform set. A row held by someone no longer on any of the set''s teams is released when the number is given out again (KitBoard::setNumber).';

INSERT INTO person_uniform_numbers (uniform_set_id, person_id, jersey_number)
SELECT DISTINCT ON (t.uniform_set_id, tp.person_id) t.uniform_set_id, tp.person_id, tp.jersey_number
  FROM team_persons tp JOIN teams t ON t.id = tp.team_id
 WHERE tp.jersey_number ~ '^[0-9]{1,3}$' AND tp.removed_at IS NULL AND t.uniform_set_id IS NOT NULL
ON CONFLICT DO NOTHING;

UPDATE team_persons SET jersey_number = NULL
 WHERE jersey_number IS NOT NULL
   AND EXISTS (SELECT 1 FROM person_uniform_numbers n JOIN teams t ON t.uniform_set_id = n.uniform_set_id
                WHERE n.person_id = team_persons.person_id AND t.id = team_persons.team_id);

DROP INDEX IF EXISTS team_persons_team_jersey_active_key;

COMMIT;
