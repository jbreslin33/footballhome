-- 👁 SEES, normalized (owner 11/17: "there is rosters, sees. and one game
-- sees" + "sees can over ride the default of seeing due to being on
-- roster" + "if its one off that is invite … must be normalized").
--
-- Three facts, nothing copied:
--   1. ROSTER  — official league list (official_roster_sources.games_team_id)
--               → that team's games by default.
--   2. SEES    — person_team_sees (person, team, yes/no): an exception to
--               the roster for EVERY game of a team. yes = standing
--               call-down (needs a league call-down rule, team_invite_caps);
--               no = restrained. Ending one sets ended_at (history kept).
--   3. ONE-GAME SEES — event_person_sees (game, person, yes/no): yes = a
--               one-off invite (who sent it, how); no = not this game.
--               Beats 1 and 2.
-- fh_event_invites becomes a VIEW that computes the answer — every reader
-- (RSVP, reminders, No Response, Game Center, carpool, fines …) keeps
-- working unchanged. Retired: team_auto_invites, game_restraints, the 72
-- copied 'auto'/'roster' invite rows, revoked_at on invites, and the six
-- sync triggers/functions that kept the copies in step.

BEGIN;

-- ── 2. SEES ────────────────────────────────────────────────────────────
CREATE TABLE person_team_sees (
  id                 serial PRIMARY KEY,
  person_id          integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  team_id            integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  sees               boolean NOT NULL,
  from_team_id       integer REFERENCES teams(id),   -- call-down: the team he comes from
  created_at         timestamptz NOT NULL DEFAULT now(),
  created_by_user_id integer,
  ended_at           timestamptz,
  ended_by_user_id   integer,
  CHECK (ended_at IS NULL OR ended_at >= created_at)
);
CREATE UNIQUE INDEX person_team_sees_open ON person_team_sees (person_id, team_id) WHERE ended_at IS NULL;
CREATE INDEX person_team_sees_team ON person_team_sees (team_id) WHERE sees;

-- A yes needs a league call-down rule (mig 1446's rule, moved here).
CREATE FUNCTION fh_person_team_sees_rule() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.sees AND NEW.ended_at IS NULL AND NOT EXISTS (
       SELECT 1 FROM team_invite_caps c WHERE c.to_team_id = NEW.team_id AND c.from_team_id = NEW.from_team_id) THEN
    RAISE EXCEPTION 'Sees yes = a call-down: needs a league call-down rule from team % to team %', NEW.from_team_id, NEW.team_id;
  END IF;
  RETURN NEW;
END $$;
CREATE TRIGGER person_team_sees_rule BEFORE INSERT OR UPDATE ON person_team_sees
  FOR EACH ROW EXECUTE FUNCTION fh_person_team_sees_rule();

-- standing call-downs: live ones open; ended ones closed at the last game
-- they were still riding (their history stays computable)
INSERT INTO person_team_sees (person_id, team_id, sees, from_team_id, created_at, ended_at)
SELECT a.person_id, a.team_id, true, a.from_team_id, a.created_at,
       CASE WHEN a.active THEN NULL ELSE GREATEST(a.created_at,
         COALESCE((SELECT max(ge.starts_at) + interval '1 minute' FROM fh_event_invites i
                     JOIN fh_events fe ON fe.id = i.fh_event_id JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE i.person_id = a.person_id AND i.channel = 'auto' AND i.revoked_at IS NULL
                      AND ge.starts_at <= now()), a.created_at)) END
  FROM team_auto_invites a
 WHERE a.active OR EXISTS (SELECT 1 FROM team_invite_caps c WHERE c.to_team_id = a.team_id AND c.from_team_id = a.from_team_id);
-- restraints
INSERT INTO person_team_sees (person_id, team_id, sees, created_at, created_by_user_id)
SELECT person_id, team_id, false, created_at, created_by_user_id FROM game_restraints;

-- ── 1. ROSTER: when a list started giving games (mig 1443 went live) ───
ALTER TABLE official_roster_sources ADD COLUMN games_from timestamptz;
UPDATE official_roster_sources SET games_from = COALESCE(
  (SELECT min(created_at) FROM fh_event_invites WHERE channel = 'roster'), now())
 WHERE games_team_id IS NOT NULL;

CREATE OR REPLACE FUNCTION fh_roster_game_grants()
RETURNS TABLE (person_id int, team_id int, from_team_id int)
LANGUAGE sql STABLE AS $$
  SELECT DISTINCT ON (n.person_id, s.games_team_id) n.person_id, s.games_team_id, s.team_id
    FROM official_roster_names n
    JOIN official_roster_sources s ON s.id = n.source_id AND s.is_active AND s.games_team_id IS NOT NULL
   WHERE n.person_id IS NOT NULL
     AND fh_in_leagueapps(n.person_id)
     AND NOT EXISTS (SELECT 1 FROM person_team_sees r WHERE r.person_id = n.person_id AND r.team_id = s.games_team_id
                        AND NOT r.sees AND r.ended_at IS NULL)
     AND NOT EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = n.person_id
                        AND tp.team_id = s.games_team_id AND tp.removed_at IS NULL)
   ORDER BY n.person_id, s.games_team_id, (s.team_id = s.games_team_id) DESC
$$;

-- ── 3. ONE-GAME SEES ───────────────────────────────────────────────────
CREATE TABLE event_person_sees (
  id                  bigserial PRIMARY KEY,
  fh_event_id         bigint  NOT NULL REFERENCES fh_events(id) ON DELETE CASCADE,
  person_id           integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  sees                boolean NOT NULL,
  from_team_id        integer REFERENCES teams(id),
  recipient_person_id integer,
  set_by_user_id      integer,
  channel             text CHECK (channel IS NULL OR channel IN ('sms', 'email', 'copy')),
  contact             text,
  note                text,
  created_at          timestamptz NOT NULL DEFAULT now(),
  UNIQUE (fh_event_id, person_id)
);
CREATE INDEX event_person_sees_person ON event_person_sees (person_id);

-- ── the answer, computed ───────────────────────────────────────────────
ALTER TABLE fh_event_invites RENAME TO fh_event_invites_retired_1450;
ALTER TABLE team_auto_invites RENAME TO team_auto_invites_retired_1450;
ALTER TABLE game_restraints RENAME TO game_restraints_retired_1450;

CREATE VIEW fh_event_invites AS
WITH rule AS (
  -- 2. sees yes: every game of the team (and its practices, unless his own
  --    team row already gives them — mig 1073), while the row was open
  SELECT DISTINCT ON (fet.fh_event_id, s.person_id)
         fet.fh_event_id, s.person_id, s.from_team_id, s.created_at, 'standing call-down'::text AS note
    FROM person_team_sees s
    JOIN fh_event_teams fet ON fet.team_id = s.team_id
    JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind IN ('match', 'practice')
    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
   WHERE s.sees AND ge.starts_at >= s.created_at AND (s.ended_at IS NULL OR ge.starts_at < s.ended_at)
     AND (fe.kind = 'match' OR NOT EXISTS (
           SELECT 1 FROM fh_event_teams f2 JOIN team_persons tp ON tp.team_id = f2.team_id AND tp.removed_at IS NULL
            WHERE f2.fh_event_id = fet.fh_event_id AND tp.person_id = s.person_id))
  UNION ALL
  -- 1. on the list → the games team's games since the list began giving them
  SELECT fet.fh_event_id, g.person_id, g.from_team_id, src.games_from, 'official league list'
    FROM fh_roster_game_grants() g
    JOIN official_roster_sources src ON src.team_id = g.from_team_id AND src.games_team_id = g.team_id AND src.is_active
    JOIN fh_event_teams fet ON fet.team_id = g.team_id
    JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
    JOIN gcal_events ge ON ge.id = fe.gcal_event_id
   WHERE ge.starts_at >= src.games_from
), one_rule AS (
  SELECT DISTINCT ON (fh_event_id, person_id) * FROM rule ORDER BY fh_event_id, person_id, created_at
)
SELECT o.id, o.fh_event_id, o.person_id, o.from_team_id, o.recipient_person_id,
       o.set_by_user_id AS invited_by_user_id, o.channel, o.contact, o.note, o.created_at,
       NULL::timestamptz AS revoked_at, NULL::integer AS revoked_by_user_id
  FROM event_person_sees o
 WHERE o.sees
UNION ALL
SELECT NULL::bigint, r.fh_event_id, r.person_id, r.from_team_id, r.person_id,
       NULL::integer, NULL::text, NULL::text, r.note, r.created_at,
       NULL::timestamptz, NULL::integer
  FROM one_rule r
 WHERE NOT EXISTS (SELECT 1 FROM event_person_sees o WHERE o.fh_event_id = r.fh_event_id AND o.person_id = r.person_id);

-- one-game rows from the old table, in order:
-- a) every live hand-sent invite (keeps its id)
INSERT INTO event_person_sees (id, fh_event_id, person_id, sees, from_team_id, recipient_person_id, set_by_user_id, channel, contact, note, created_at)
SELECT i.id, i.fh_event_id, i.person_id, true, i.from_team_id, i.recipient_person_id, i.invited_by_user_id,
       i.channel, i.contact, i.note, i.created_at
  FROM fh_event_invites_retired_1450 i
 WHERE i.revoked_at IS NULL AND COALESCE(i.channel, '') NOT IN ('auto', 'roster')
   AND EXISTS (SELECT 1 FROM fh_events fe WHERE fe.id = i.fh_event_id);
SELECT setval('event_person_sees_id_seq', GREATEST((SELECT max(id) FROM event_person_sees),
              (SELECT max(id) FROM fh_event_invites_retired_1450), 1));
-- b) a coach took him off one game the rules would give him → no
INSERT INTO event_person_sees (fh_event_id, person_id, sees, set_by_user_id, note, created_at)
SELECT DISTINCT ON (i.fh_event_id, i.person_id) i.fh_event_id, i.person_id, false, i.revoked_by_user_id, 'taken off this game', i.revoked_at
  FROM fh_event_invites_retired_1450 i
 WHERE i.revoked_at IS NOT NULL AND i.revoked_by_user_id IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM event_person_sees o WHERE o.fh_event_id = i.fh_event_id AND o.person_id = i.person_id)
   AND EXISTS (SELECT 1 FROM fh_event_invites v WHERE v.fh_event_id = i.fh_event_id AND v.person_id = i.person_id)
 ORDER BY i.fh_event_id, i.person_id, i.revoked_at DESC;
-- c) a copied row the rules no longer reproduce (history of an ended rule) → yes
INSERT INTO event_person_sees (fh_event_id, person_id, sees, from_team_id, recipient_person_id, note, created_at)
SELECT i.fh_event_id, i.person_id, true, i.from_team_id, i.recipient_person_id,
       CASE i.channel WHEN 'auto' THEN 'standing call-down' ELSE 'official league list' END, i.created_at
  FROM fh_event_invites_retired_1450 i
 WHERE i.revoked_at IS NULL AND i.channel IN ('auto', 'roster')
   AND EXISTS (SELECT 1 FROM fh_events fe WHERE fe.id = i.fh_event_id)
   AND NOT EXISTS (SELECT 1 FROM fh_event_invites v WHERE v.fh_event_id = i.fh_event_id AND v.person_id = i.person_id);

-- ── retired: the copy machinery ────────────────────────────────────────
DROP TRIGGER IF EXISTS trg_roster_game_invites ON fh_event_teams;
DROP TRIGGER IF EXISTS trg_team_auto_invites ON fh_event_teams;
DROP TRIGGER IF EXISTS trg_game_restraints_sync ON game_restraints_retired_1450;
DROP TRIGGER IF EXISTS trg_team_auto_invites_call_down_only ON team_auto_invites_retired_1450;
DROP FUNCTION IF EXISTS fh_roster_game_invites_on_tag();
DROP FUNCTION IF EXISTS fh_apply_team_auto_invites();
DROP FUNCTION IF EXISTS fh_roster_game_restraint_changed();
DROP FUNCTION IF EXISTS fh_team_auto_invites_call_down_only();
DROP FUNCTION IF EXISTS fh_team_auto_invites_backfill(integer, integer, integer);
DROP FUNCTION IF EXISTS fh_auto_invite_wanted(bigint, integer);

CREATE OR REPLACE FUNCTION public.fh_official_roster_reconcile(p_source integer)
 RETURNS integer
 LANGUAGE plpgsql
AS $function$
DECLARE v_team integer; n integer := 0;
BEGIN
    SELECT team_id INTO v_team FROM official_roster_sources WHERE id = p_source;
    -- An empty list is a failed parse, never "the league dropped everyone".
    IF v_team IS NULL OR NOT EXISTS (SELECT 1 FROM official_roster_names WHERE source_id = p_source) THEN
        RETURN 0;
    END IF;

    UPDATE team_persons tp
       SET removed_at = now(), removed_reason = 'league_list_drop',
           removed_details = jsonb_build_object('source_id', p_source, 'mig', 1026)
      FROM official_roster_seen s
     WHERE s.source_id = p_source AND tp.person_id = s.person_id
       AND tp.team_id = v_team AND tp.removed_at IS NULL AND tp.call_in
       AND NOT EXISTS (SELECT 1 FROM official_roster_names n
                        WHERE n.source_id = p_source AND n.person_id = s.person_id);
    GET DIAGNOSTICS n = ROW_COUNT;

    DELETE FROM official_roster_seen s
     WHERE s.source_id = p_source
       AND NOT EXISTS (SELECT 1 FROM official_roster_names n
                        WHERE n.source_id = p_source AND n.person_id = s.person_id);
    INSERT INTO official_roster_seen (source_id, person_id)
    SELECT DISTINCT p_source, person_id FROM official_roster_names
     WHERE source_id = p_source AND person_id IS NOT NULL
    ON CONFLICT DO NOTHING;
    -- On a list → sees the games unless sees says no: computed by the
    -- fh_event_invites view (mig 1450), nothing to sync.
    RETURN n;
END $function$;

DROP FUNCTION IF EXISTS fh_sync_roster_game_invites();

-- 👁 SEES reads the new rows
CREATE OR REPLACE FUNCTION public.fh_person_sees(p_ids integer[])
 RETURNS TABLE(person_id integer, sees jsonb, suspended boolean, injured boolean)
 LANGUAGE sql
 STABLE
AS $function$
  WITH board_all AS (
    SELECT t.id, t.club_id, t.club_section_id, t.games_need_roster,
           COALESCE(NULLIF(t.short_label, ''), NULLIF(t.label, ''), t.name) AS team,
           t.board_sort_order,
           fh_team_callup_only(t.id) AS callup_only,
           -- A team with no practices on the calendar (the Cup) never says
           -- "practices" — only events still ahead.
           EXISTS (SELECT 1 FROM fh_event_teams fet JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'practice'
                     JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE fet.team_id = t.id AND ge.deleted_at IS NULL AND ge.starts_at > now()) AS has_practices,
           EXISTS (SELECT 1 FROM fh_event_teams fet JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind IN ('match','intrasquad')
                     JOIN gcal_events ge ON ge.id = fe.gcal_event_id
                    WHERE fet.team_id = t.id AND ge.deleted_at IS NULL AND ge.starts_at > now()) AS has_games
      FROM teams t
     WHERE t.is_active AND (t.board_sort_order IS NOT NULL OR t.rsvp_board)
  ), board AS (
    -- A team with no events of its own is a ROSTER, not a schedule (APSL
    -- Reserves = the APSL Reserve Roster; its men play APSL's games —
    -- owner 11/17 "there are no reserve games or reserve practices") —
    -- it shows under 📋 ROSTERS, never under 👁 SEES.
    SELECT * FROM board_all WHERE has_games OR has_practices
  ), standing AS (
    SELECT s.person_id, s.team_id FROM person_team_sees s
     WHERE s.sees AND s.ended_at IS NULL AND s.person_id = ANY(p_ids)
  ), player AS (
    SELECT tp.person_id, b.id AS team_id, b.team, b.board_sort_order, 'player'::text AS role,
           ss.code AS squad, b.has_practices, b.has_games,
           -- owes nothing at all here
           (ss.code = 'inactive' OR (ss.id IS NULL AND tp.invite_only AND NOT b.games_need_roster)) AS idle,
           tp.invite_only AS practice_only, b.callup_only,
           EXISTS (SELECT 1 FROM standing s WHERE s.person_id = tp.person_id AND s.team_id = b.id) AS standing
      FROM team_persons tp
      JOIN board b ON b.id = tp.team_id
      LEFT JOIN squad_statuses ss ON ss.id = tp.squad_status_id
     WHERE tp.removed_at IS NULL AND tp.person_id = ANY(p_ids)
  ), rows AS (
    SELECT p.person_id, p.team_id, p.team, p.board_sort_order, p.role,
           CASE WHEN p.standing THEN 'invite'
                WHEN p.idle THEN 'no'
                WHEN p.practice_only THEN 'no'
                WHEN NOT p.has_games THEN 'no'
                WHEN p.callup_only THEN 'callup'
                ELSE 'yes' END AS games,
           CASE WHEN p.idle OR NOT p.has_practices THEN 'no' ELSE 'yes' END AS practices,
           NULL::int[] AS days,
           CASE WHEN p.idle THEN 'inactive'
                WHEN p.squad = 'practice_squad' THEN 'practice_squad'
                WHEN p.practice_only THEN 'not_on_roster'
                WHEN p.standing THEN 'standing_invite'
                WHEN p.callup_only THEN 'callup_only' END AS note
      FROM player p
    UNION ALL
    -- ⭐ standing invite where he has no roster row
    SELECT s.person_id, b.id, b.team, b.board_sort_order, 'player', 'invite', 'no', NULL, 'standing_invite'
      FROM standing s JOIN board b ON b.id = s.team_id
     WHERE NOT EXISTS (SELECT 1 FROM player p WHERE p.person_id = s.person_id AND p.team_id = s.team_id)
    UNION ALL
    -- 📋 on an official list → that team's games (mig 1443)
    SELECT g.person_id, b.id, b.team, b.board_sort_order, 'player',
           CASE WHEN b.has_games THEN 'yes' ELSE 'no' END, 'no', NULL, 'official_list'
      FROM fh_roster_game_grants() g JOIN board b ON b.id = g.team_id
     WHERE g.person_id = ANY(p_ids)
    UNION ALL
    -- 🚫 restrained from a team's games he'd get through a list
    SELECT r.person_id, b.id, b.team, b.board_sort_order, 'player', 'no', 'no', NULL, 'restrained'
      FROM person_team_sees r JOIN board b ON b.id = r.team_id
     WHERE NOT r.sees AND r.ended_at IS NULL AND r.person_id = ANY(p_ids)
       AND NOT EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = r.person_id
                          AND tp.team_id = r.team_id AND tp.removed_at IS NULL)
    UNION ALL
    SELECT c.person_id, b.id, b.team, b.board_sort_order, 'coach',
           CASE WHEN cs.practices_only OR NOT b.has_games THEN 'no' ELSE 'yes' END,
           CASE WHEN NOT b.has_practices THEN 'no'
                WHEN cs.id IS NULL THEN 'yes'
                WHEN EXISTS (SELECT 1 FROM coach_schedule_days d WHERE d.coach_schedule_id = cs.id) THEN 'days'
                ELSE 'no' END,
           (SELECT array_agg(d.isodow::int ORDER BY d.isodow) FROM coach_schedule_days d WHERE d.coach_schedule_id = cs.id),
           CASE WHEN cs.practices_only THEN 'volunteer' END
      FROM team_coaches tc
      JOIN coaches c ON c.id = tc.coach_id
      JOIN board b ON b.id = tc.team_id
      LEFT JOIN coach_schedules cs ON cs.coach_id = c.id AND cs.club_section_id = b.club_section_id
     WHERE tc.ended_at IS NULL AND c.person_id = ANY(p_ids)
    UNION ALL
    SELECT DISTINCT cst.person_id, b.id, b.team, b.board_sort_order, 'staff',
           CASE WHEN b.has_games THEN 'yes' ELSE 'no' END,
           CASE WHEN b.has_practices THEN 'yes' ELSE 'no' END, NULL::int[], NULL::text
      FROM club_staff cst CROSS JOIN board b
     WHERE cst.ended_at IS NULL AND cst.person_id = ANY(p_ids)
  )
  SELECT pid AS person_id,
         COALESCE((SELECT jsonb_agg(jsonb_build_object(
                     'team_id', r.team_id, 'team', r.team, 'role', r.role, 'games', r.games,
                     'practices', r.practices, 'days', to_jsonb(r.days), 'note', r.note,
                     'pill_bg', (SELECT tc.card_pill_bg FROM teams tc WHERE tc.id = r.team_id),
                     'pill_fg', (SELECT tc.card_pill_fg FROM teams tc WHERE tc.id = r.team_id),
                     'section', (SELECT tc.gender_category FROM teams tc WHERE tc.id = r.team_id))
                   ORDER BY r.board_sort_order NULLS LAST, r.team, r.role)
                     FROM rows r WHERE r.person_id = pid), '[]'::jsonb) AS sees,
         EXISTS (SELECT 1 FROM rsvp_suspensions s WHERE s.person_id = pid
                  AND s.starts_at <= now() AND (s.ends_at IS NULL OR s.ends_at > now())) AS suspended,
         EXISTS (SELECT 1 FROM person_injuries i JOIN health_statuses h ON h.id = i.health_status_id AND h.is_injured
                  WHERE i.person_id = pid AND i.starts_at <= now() AND (i.ends_at IS NULL OR i.ends_at > now())) AS injured
    FROM unnest(p_ids) AS pid
$function$;

COMMIT;
