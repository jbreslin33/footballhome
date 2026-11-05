-- 1098: call-up candidates keep coming FROM APSL Reserves after mig 1097
-- took Reserves off games: the gated branch of fh_event_invite_candidates
-- reads the game's list teams (its teams + the call-up pools serving them),
-- so a Reserves call-up still says "CALL-UP · Reserves", not Liga 1.
CREATE OR REPLACE FUNCTION public.fh_event_invite_candidates(p_fh_event_id bigint)
 RETURNS TABLE(person_id integer, from_team_id integer, from_team_name text, single_age integer, basis text)
 LANGUAGE sql
 STABLE
AS $function$
  WITH tagged AS (
    SELECT t.* FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
     WHERE fet.fh_event_id = p_fh_event_id
  ),
  youth AS (
    SELECT cu.person_id, cu.from_team_id, cu.from_team_name, cu.single_age, 'callup'::text AS basis
      FROM fh_event_callups(p_fh_event_id) cu
     WHERE EXISTS (SELECT 1 FROM tagged WHERE gender_category IN ('boys','girls'))
  ),
  -- Call-up-gated tagged teams (mig 603): roster membership grants no
  -- visibility, so the roster itself is the squad the coach picks from.
  gated AS (
    SELECT DISTINCT ON (p.id)
           p.id AS person_id, t.id AS from_team_id, t.name::text AS from_team_name,
           NULL::int AS single_age, 'squad'::text AS basis
      -- mig 1098: plus the call-up pools serving the game's teams (APSL
      -- Reserves is never tagged since mig 1097, still its pool).
      FROM teams t
      JOIN team_persons tp ON tp.team_id = t.id AND tp.removed_at IS NULL
      JOIN persons p ON p.id = tp.person_id
     WHERE fh_team_callup_only(t.id)
       AND t.id IN (SELECT fh_event_list_team_ids(p_fh_event_id))
     ORDER BY p.id, t.id
  ),
  -- 📄 Paper spots (mig 619): invite-only members of a tagged team are
  -- pickable from their own squad.
  paper AS (
    SELECT DISTINCT ON (p.id)
           p.id AS person_id, t.id AS from_team_id, t.name::text AS from_team_name,
           NULL::int AS single_age, 'paper'::text AS basis
      FROM tagged t
      JOIN team_persons tp ON tp.team_id = t.id AND tp.removed_at IS NULL AND tp.invite_only
      JOIN persons p ON p.id = tp.person_id
     WHERE NOT fh_team_callup_only(t.id)
       AND NOT EXISTS (SELECT 1 FROM team_persons x JOIN tagged y ON y.id = x.team_id
                        WHERE x.person_id = p.id AND x.removed_at IS NULL
                          AND NOT x.invite_only AND NOT fh_team_callup_only(y.id))
     ORDER BY p.id, t.id
  ),
  adult AS (
    SELECT DISTINCT ON (p.id)
           p.id AS person_id, t.id AS from_team_id, t.name::text AS from_team_name,
           NULL::int AS single_age, 'squad'::text AS basis
      FROM tagged tg
      JOIN teams t ON t.club_id = tg.club_id
                  AND t.club_section_id = tg.club_section_id
                  AND t.gender_category = tg.gender_category
                  AND t.is_active AND NOT t.is_pool AND t.board_archived_at IS NULL
                  AND t.id NOT IN (SELECT id FROM tagged)
      JOIN team_persons tp ON tp.team_id = t.id AND tp.removed_at IS NULL
      JOIN persons p ON p.id = tp.person_id
     WHERE tg.gender_category IN ('mens','womens')
       -- A paper spot on a tagged team does not make them "rostered here"
       -- (mig 619) — but the paper branch already lists them, so skip.
       AND NOT EXISTS (SELECT 1 FROM team_persons x JOIN tagged y ON y.id = x.team_id
                        WHERE x.person_id = p.id AND x.removed_at IS NULL
                          AND NOT x.invite_only AND NOT fh_team_callup_only(y.id))
       AND NOT EXISTS (SELECT 1 FROM gated g WHERE g.person_id = p.id)
       AND NOT EXISTS (SELECT 1 FROM paper pp WHERE pp.person_id = p.id)
     ORDER BY p.id, t.id
  )
  SELECT c.* FROM (SELECT * FROM youth
                   UNION ALL SELECT * FROM gated
                   UNION ALL SELECT * FROM paper
                   UNION ALL SELECT * FROM adult) c
   WHERE NOT fh_event_invited(p_fh_event_id, c.person_id)
$function$;
