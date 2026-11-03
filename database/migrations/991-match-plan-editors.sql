-- 991-match-plan-editors.sql (2026-11-03)
--
-- 🎯 Match plan: only the people on match_plan_editors edit the set pieces
-- and tactics.  Owner 11/3: "only me can edit" — Lopez and Vazquez are
-- staff, not men's coaches, and passed only as club staff / admins.
-- Mig 966 let any coach of the game's teams, club staff and club/super
-- admins edit; now it is this list alone (James, person 1).  Add an
-- editor by migration.
--
-- Reading is unchanged: everyone on the game, their parents, the game's
-- coaches and club staff (fh_match_plan_reader no longer leans on the
-- editor check for those last two).  Checklist ticks stay each viewer's own.

CREATE TABLE IF NOT EXISTS match_plan_editors (
    person_id   INT PRIMARY KEY REFERENCES persons(id) ON DELETE CASCADE,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO match_plan_editors (person_id)
SELECT id FROM persons WHERE id = 1
ON CONFLICT DO NOTHING;

CREATE OR REPLACE FUNCTION fh_match_plan_editor(p_fh_event_id BIGINT, p_person_id INTEGER)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM match_plan_editors e WHERE e.person_id = p_person_id)
$$;

CREATE OR REPLACE FUNCTION fh_match_plan_reader(p_fh_event_id BIGINT, p_person_id INTEGER)
RETURNS BOOLEAN LANGUAGE sql STABLE AS $$
  WITH party AS (
      SELECT tp.person_id FROM fh_event_teams fet
        JOIN team_persons tp ON tp.team_id = fet.team_id AND tp.removed_at IS NULL
                            AND NOT fh_team_callup_only(tp.team_id) AND NOT tp.invite_only
       WHERE fet.fh_event_id = p_fh_event_id
      UNION
      SELECT i.person_id FROM fh_event_invites i
       WHERE i.fh_event_id = p_fh_event_id AND i.revoked_at IS NULL)
  SELECT EXISTS (SELECT 1 FROM party WHERE person_id = p_person_id)
      OR EXISTS (SELECT 1 FROM party pa WHERE fh_is_guardian(p_person_id, pa.person_id))
      OR EXISTS (SELECT 1 FROM fh_event_teams fet
                   JOIN team_coaches tc ON tc.team_id = fet.team_id AND tc.ended_at IS NULL
                   JOIN coaches co ON co.id = tc.coach_id
                  WHERE fet.fh_event_id = p_fh_event_id AND co.person_id = p_person_id)
      OR fh_event_staff(p_fh_event_id, p_person_id)
      OR fh_match_plan_editor(p_fh_event_id, p_person_id)
$$;
