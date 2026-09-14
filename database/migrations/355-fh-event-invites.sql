-- 355 — Game invites: call-ups (youth) and play-downs / play-ups (adults).
-- Owner 2026-09-13: "lets build the invite link for play-downs and call-ups".
--
-- Since 2026-09-12 a game is tagged with ONE youth team and club-pass
-- call-ups no longer see it.  Men's CASA games now tag Liga 1 only, so
-- the (max two per week) APSL players going down don't see those either.
-- This table is the explicit opt-in: a coach or admin invites ONE named
-- player to ONE game and sends them a per-person magic link.  An open
-- invite makes the game visible to the player (or the parent, for youth),
-- gives them a Go/No row, and lists them on the coach's roster for that
-- game.  Nothing is derived from age or squad any more — an invite row
-- is the only way in.
--
-- Rows are never deleted: revoke instead, so the audit trail stays whole
-- and a re-invite is a new row.
BEGIN;

CREATE TABLE IF NOT EXISTS fh_event_invites (
  id                  serial PRIMARY KEY,
  fh_event_id         bigint NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
  person_id           int    NOT NULL REFERENCES persons(id),     -- the PLAYER
  from_team_id        int    REFERENCES teams(id),                -- their own squad at invite time
  recipient_person_id int    REFERENCES persons(id),              -- who the link went to (parent for youth)
  invited_by_user_id  int    REFERENCES users(id),
  channel             text   CHECK (channel IS NULL OR channel IN ('sms','email','copy')),
  contact             text,
  note                text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  revoked_at          timestamptz,
  revoked_by_user_id  int    REFERENCES users(id)
);
CREATE UNIQUE INDEX IF NOT EXISTS fh_event_invites_open_idx
  ON fh_event_invites (fh_event_id, person_id) WHERE revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS fh_event_invites_person_idx
  ON fh_event_invites (person_id) WHERE revoked_at IS NULL;
COMMENT ON TABLE fh_event_invites IS
  'One named player invited to one game they are not rostered for (youth call-up, men''s play-down/up). Open row = visible + RSVP-able + on the coach list. Never delete; revoke.';

-- Is this person let into the event by an open invite?
CREATE OR REPLACE FUNCTION fh_event_invited(p_fh_event_id bigint, p_person_id int)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT EXISTS (SELECT 1 FROM fh_event_invites i
                  WHERE i.fh_event_id = p_fh_event_id AND i.person_id = p_person_id
                    AND i.revoked_at IS NULL)
$$;

-- Who COULD be invited to this event.
--   youth  → club-pass call-ups (fh_event_callups, migration 329): same
--            program, up to club_pass_years_up younger, not on a tagged team.
--   adults → players on any other active, non-pool team in the same club
--            section as a tagged team (APSL ⇄ Liga 1 ⇄ Reserves), not on a
--            tagged team.
-- Excludes anyone with an open invite already.
CREATE OR REPLACE FUNCTION fh_event_invite_candidates(p_fh_event_id bigint)
RETURNS TABLE (person_id int, from_team_id int, from_team_name text, single_age int, basis text)
LANGUAGE sql STABLE AS $$
  WITH tagged AS (
    SELECT t.* FROM fh_event_teams fet JOIN teams t ON t.id = fet.team_id
     WHERE fet.fh_event_id = p_fh_event_id
  ),
  youth AS (
    SELECT cu.person_id, cu.from_team_id, cu.from_team_name, cu.single_age, 'callup'::text AS basis
      FROM fh_event_callups(p_fh_event_id) cu
     WHERE EXISTS (SELECT 1 FROM tagged WHERE gender_category IN ('boys','girls'))
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
       AND NOT EXISTS (SELECT 1 FROM team_persons x JOIN tagged y ON y.id = x.team_id
                        WHERE x.person_id = p.id AND x.removed_at IS NULL)
     ORDER BY p.id, t.id
  )
  SELECT c.* FROM (SELECT * FROM youth UNION ALL SELECT * FROM adult) c
   WHERE NOT fh_event_invited(p_fh_event_id, c.person_id)
$$;

COMMIT;
