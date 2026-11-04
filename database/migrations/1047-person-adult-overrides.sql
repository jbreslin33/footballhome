-- 1047: an adult LeagueApps-registered in a youth program counts as an
-- adult only (owner 2026-11-04: "take sheldon out of the boys LA count. he
-- should only be adult").  LeagueApps is read-only for us (normalize on
-- FH, not sources), so the correction is an FH row:
-- person_adult_overrides.  A person here is never a youth member — not on
-- the Boys/Girls board, not placed on a youth team by a new youth
-- membership (fn_youth_place_on_membership).  First row: Sheldon Rhoden
-- (22433, b. 2009, APSL; LA has him in the Boys Club membership).

BEGIN;

CREATE TABLE IF NOT EXISTS person_adult_overrides (
    person_id   integer PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    note        text,
    created_at  timestamptz NOT NULL DEFAULT now()
);
COMMENT ON TABLE person_adult_overrides IS
  'mig 1047: people LeagueApps lists in a youth program whom the club treats as adults only — kept off the Boys/Girls board and youth placement.';

INSERT INTO person_adult_overrides (person_id, note)
SELECT 22433, 'APSL man; LA registration sits in the Boys Club membership (owner 2026-11-04)'
 WHERE EXISTS (SELECT 1 FROM persons WHERE id = 22433 AND first_name = 'Sheldon' AND last_name = 'Rhoden')
ON CONFLICT (person_id) DO NOTHING;

CREATE OR REPLACE FUNCTION fn_youth_place_on_membership() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.ended_at IS NULL
       AND NOT EXISTS (SELECT 1 FROM person_adult_overrides o WHERE o.person_id = NEW.person_id)
       AND EXISTS (SELECT 1 FROM leagueapps_programs lp
                    WHERE lp.program_id = NEW.la_program_id
                      AND lp.variant = 'active' AND lp.category IN ('boys', 'girls')) THEN
        PERFORM fh_youth_place(NEW.person_id);
    END IF;
    RETURN NULL;
END $$;

COMMIT;
