-- 693 (2026-10-24) — Coaches are not fined; regular players are.  Owner:
-- "clear my fines lol" → "clear luke fines and acevedo" → "and victor" →
-- "and sheldon" → "since they are coaching" → "and probably got confused."
-- → "normal players only have no excuse."
--
-- Fines are derived (fh_person_fines, mig 460).  A standing exemption:
--   * anyone with a live team_coaches row (any team, any section) — James
--     Breslin, Luke Breslin, Victor Baidal today; future coaches too;
--   * fine_exempt_persons — people who coach without a coach record
--     (Sheldon Rhoden), added by name.
-- Their current fines disappear and none accrue while it holds.  Anthony
-- Acevedo coaches and is on no fined roster: nothing to clear.

CREATE TABLE IF NOT EXISTS fine_exempt_persons (
    person_id  INT PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    reason     TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
COMMENT ON TABLE fine_exempt_persons IS
    'mig 693: never fined — people who coach without a team_coaches row. Live coaches are exempt automatically in fh_person_fines.';

CREATE OR REPLACE FUNCTION fh_fine_exempt(p_person int) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (SELECT 1 FROM fine_exempt_persons x WHERE x.person_id = p_person)
        OR EXISTS (SELECT 1 FROM coaches co JOIN team_coaches tc ON tc.coach_id = co.id AND tc.ended_at IS NULL
                    WHERE co.person_id = p_person)
$$;
COMMENT ON FUNCTION fh_fine_exempt(int) IS 'mig 693: coaches (live team_coaches) and fine_exempt_persons are never fined.';

DO $$
DECLARE d text;
BEGIN
    d := pg_get_functiondef('fh_person_fines'::regproc);
    IF position('fh_fine_exempt' IN d) = 0 THEN
        d := replace(d,
            '       -- Injured on the event day: no fine (mig 510).',
            '       -- Coaches are not fined; regular players are (mig 693).
       AND NOT fh_fine_exempt(tp.person_id)
       -- Injured on the event day: no fine (mig 510).');
        IF position('fh_fine_exempt' IN d) = 0 THEN
            RAISE EXCEPTION 'mig 693: fh_person_fines anchor not found';
        END IF;
        EXECUTE d;
    END IF;
END $$;

INSERT INTO fine_exempt_persons (person_id, reason)
SELECT p.id, 'coaches without a coach record (owner 2026-10-24)'
  FROM persons p WHERE p.first_name = 'Sheldon' AND p.last_name = 'Rhoden'
ON CONFLICT (person_id) DO NOTHING;
