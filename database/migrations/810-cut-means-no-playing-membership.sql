-- 810 (2026-10-29) — "cut" = no live PLAYING membership; pickup doesn't count.
--
-- Mig 807 counted any live LeagueApps membership, so a player moved off the
-- Men's Club membership onto Pickup still read as registered and never got
-- the ✂ flag. Owner: "we removed them from la with intention to cut them".
-- Live case on the APSL Reserves TeamPass list: Dylan Moreno 22371,
-- Nicholson Pennant 22450, Ando Andre 22494 (+ Djosonde Anathol 22386,
-- Shahzaib Samuel 22495) — all pickup-only.
--
-- Playing = a program whose leagueapps_programs.variant is 'active' (Pickup
-- and Inactive memberships are not on a team).

CREATE OR REPLACE FUNCTION fh_in_leagueapps(p_person_id integer) RETURNS boolean
LANGUAGE sql STABLE AS $$
    SELECT EXISTS (SELECT 1 FROM person_la_memberships m
                     JOIN leagueapps_programs lp ON lp.program_id = m.la_program_id
                    WHERE m.person_id = p_person_id AND m.ended_at IS NULL
                      AND lp.variant = 'active')
$$;
COMMENT ON FUNCTION fh_in_leagueapps(integer) IS 'mig 810: a live PLAYING LeagueApps membership (variant active; pickup/inactive don''t count). On a league list without one = cut, still owed a drop.';
