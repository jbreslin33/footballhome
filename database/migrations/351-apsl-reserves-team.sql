-- 351 — APSL Reserves as its own board team (owner 2026-09-12: "we need
-- to differentiate if a Liga 1 player is just on Liga 1 or also on APSL
-- reserves").
--
-- Liga 1 is the club's official APSL reserve side (player-team-rules),
-- but not every Liga 1 player is registered with APSL.  Roster status
-- is a per-league pipeline (migration 342: the dropdown on a column is
-- its league's list), so "also on APSL reserves" cannot be a Liga 1
-- status value — that would put an APSL fact inside the CASA Select
-- pipeline and could not hold the two independent states (On Roster
-- with Liga 1, Needs ITC with APSL).
--
-- The shape that already works: a second team.  Multi-assign (2026-08-16,
-- MensTeamAssignments::addAssignmentForPerson) lets a person hold any
-- number of active team_persons rows, each with its own league status.
-- So a Liga 1 player who is also APSL Reserves gets a row on this team
-- with an APSL-pipeline status, next to his Liga 1 row with a CASA one.
-- No code change: the column appears on #teams from board_sort_order.
--
-- Board order for men becomes APSL (4) → APSL Reserves (5) → Liga 1 (6)
-- so the two APSL columns sit together.  mutex_group stays NULL.
BEGIN;

UPDATE teams SET board_sort_order = 6 WHERE id = 120;   -- Liga 1

INSERT INTO teams (name, slug, gender_category, division_id, club_id, club_section_id,
                   source_system_id, roster_source, label, short_label, color,
                   board_sort_order, mutex_group, max_roster, field_size, is_active, logo_url)
SELECT 'Lighthouse Mens Club APSL Reserves',
       'lighthouse-mens-club-apsl-reserves',
       'mens',
       a.division_id,                         -- same APSL division as the first team
       a.club_id,
       a.club_section_id,
       (SELECT id FROM source_systems WHERE name = 'internal'),
       'direct',
       '🏆 APSL Reserves',
       'APSL Res',
       '#1d4ed8',
       5,
       NULL,
       a.max_roster,
       11,
       true,
       a.logo_url
  FROM teams a
 WHERE a.id = 35                              -- Lighthouse Mens Club APSL
   AND NOT EXISTS (SELECT 1 FROM teams WHERE slug = 'lighthouse-mens-club-apsl-reserves');

-- ── Guard ──────────────────────────────────────────────────────────────
DO $$
DECLARE league TEXT; n INT; dup INT;
BEGIN
    SELECT l.name INTO league
      FROM teams t JOIN divisions d ON d.id = t.division_id
      JOIN seasons s ON s.id = d.season_id JOIN leagues l ON l.id = s.league_id
     WHERE t.slug = 'lighthouse-mens-club-apsl-reserves' AND t.is_active AND t.board_sort_order = 5;
    IF league IS DISTINCT FROM 'American Premier Soccer League' THEN
        RAISE EXCEPTION 'APSL Reserves did not land in the APSL league (got %)', league;
    END IF;

    -- Its league has a status pipeline for the column dropdown.
    SELECT count(*) INTO n
      FROM teams t JOIN divisions d ON d.id = t.division_id JOIN seasons s ON s.id = d.season_id
      JOIN league_roster_statuses lrs ON lrs.league_id = s.league_id
     WHERE t.slug = 'lighthouse-mens-club-apsl-reserves';
    IF n = 0 THEN
        RAISE EXCEPTION 'APSL Reserves league has no roster status list';
    END IF;

    -- Men's board sort orders stay unique.
    SELECT count(*) - count(DISTINCT board_sort_order) INTO dup
      FROM teams WHERE gender_category = 'mens' AND is_active AND board_sort_order IS NOT NULL;
    IF dup <> 0 THEN
        RAISE EXCEPTION 'Duplicate mens board_sort_order';
    END IF;
END $$;

COMMIT;
