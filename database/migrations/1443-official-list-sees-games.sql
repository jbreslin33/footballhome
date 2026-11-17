-- On an official league list → you see that team's GAMES, unless restrained
-- (owner 11/17 "better system. if on a roster you see the game UNLESS we
-- restrain it. we just need the restraint mechanism" + "do i need to add
-- apsl reserves to gcal or can it be understood they are on roster for apsl").
--
-- • official_roster_sources.games_team_id: whose games the list qualifies
--   for. APSL Active + APSL Reserve Roster → APSL; CASA L1 → L1. Youth
--   lists stay NULL (kids see games through their team already). No gcal
--   tagging for Reserves — the list itself points at APSL.
-- • game_restraints (person, team): 🚫 restrained = not asked about that
--   team's games through the list. A one-game invite still works.
-- • Mechanism = the invite every screen already honours (fh_event_invites,
--   channel 'roster', from_team_id = the list's team): one per upcoming
--   game for each list man in LeagueApps, not restrained, and not already
--   on the games team (his team row decides then). Synced after every list
--   pull (fh_official_roster_reconcile), when a game is tagged, and when a
--   restraint changes. A coach's own revoke of one game is respected.

ALTER TABLE official_roster_sources ADD COLUMN IF NOT EXISTS games_team_id integer REFERENCES teams(id);
UPDATE official_roster_sources SET games_team_id = 35  WHERE id IN (1, 6);   -- APSL Active, APSL Reserve Roster
UPDATE official_roster_sources SET games_team_id = 120 WHERE id = 2;         -- CASA L1

ALTER TABLE fh_event_invites DROP CONSTRAINT IF EXISTS fh_event_invites_channel_check;
ALTER TABLE fh_event_invites ADD CONSTRAINT fh_event_invites_channel_check
  CHECK (channel IS NULL OR channel = ANY (ARRAY['sms', 'email', 'copy', 'auto', 'roster']));

CREATE TABLE IF NOT EXISTS game_restraints (
  person_id          integer NOT NULL REFERENCES persons(id) ON DELETE CASCADE,
  team_id            integer NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
  created_at         timestamptz NOT NULL DEFAULT now(),
  created_by_user_id integer,
  PRIMARY KEY (person_id, team_id)
);

-- Who the lists put on which team's games right now.
CREATE OR REPLACE FUNCTION fh_roster_game_grants()
RETURNS TABLE (person_id int, team_id int, from_team_id int)
LANGUAGE sql STABLE AS $$
  SELECT DISTINCT ON (n.person_id, s.games_team_id) n.person_id, s.games_team_id, s.team_id
    FROM official_roster_names n
    JOIN official_roster_sources s ON s.id = n.source_id AND s.is_active AND s.games_team_id IS NOT NULL
   WHERE n.person_id IS NOT NULL
     AND fh_in_leagueapps(n.person_id)
     AND NOT EXISTS (SELECT 1 FROM game_restraints r WHERE r.person_id = n.person_id AND r.team_id = s.games_team_id)
     AND NOT EXISTS (SELECT 1 FROM team_persons tp WHERE tp.person_id = n.person_id
                        AND tp.team_id = s.games_team_id AND tp.removed_at IS NULL)
   ORDER BY n.person_id, s.games_team_id, (s.team_id = s.games_team_id) DESC
$$;

CREATE OR REPLACE FUNCTION fh_sync_roster_game_invites()
RETURNS integer LANGUAGE plpgsql AS $$
DECLARE n_add int; n_drop int;
BEGIN
  WITH games AS (
    SELECT DISTINCT fet.fh_event_id, fet.team_id
      FROM fh_event_teams fet
      JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
      JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL AND ge.starts_at > now()
     WHERE fet.team_id IN (SELECT games_team_id FROM official_roster_sources WHERE games_team_id IS NOT NULL)
  ), want AS (
    SELECT g.fh_event_id, gr.person_id, gr.from_team_id
      FROM games g JOIN fh_roster_game_grants() gr ON gr.team_id = g.team_id
  ), dropped AS (
    UPDATE fh_event_invites i SET revoked_at = now()
      FROM games g
     WHERE i.fh_event_id = g.fh_event_id AND i.channel = 'roster' AND i.revoked_at IS NULL
       AND NOT EXISTS (SELECT 1 FROM want w WHERE w.fh_event_id = i.fh_event_id AND w.person_id = i.person_id)
    RETURNING 1
  )
  SELECT count(*) INTO n_drop FROM dropped;

  INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel, note)
  SELECT w.fh_event_id, w.person_id, w.from_team_id, w.person_id, 'roster', 'official league list'
    FROM (SELECT g.fh_event_id, gr.person_id, gr.from_team_id
            FROM (SELECT DISTINCT fet.fh_event_id, fet.team_id
                    FROM fh_event_teams fet
                    JOIN fh_events fe ON fe.id = fet.fh_event_id AND fe.kind = 'match'
                    JOIN gcal_events ge ON ge.id = fe.gcal_event_id AND ge.deleted_at IS NULL AND ge.starts_at > now()) g
            JOIN fh_roster_game_grants() gr ON gr.team_id = g.team_id) w
   WHERE NOT EXISTS (SELECT 1 FROM fh_event_invites i WHERE i.fh_event_id = w.fh_event_id
                        AND i.person_id = w.person_id AND i.revoked_at IS NULL)
     -- a coach took him off this one game by hand: respected
     AND NOT EXISTS (SELECT 1 FROM fh_event_invites i WHERE i.fh_event_id = w.fh_event_id
                        AND i.person_id = w.person_id AND i.channel = 'roster' AND i.revoked_by_user_id IS NOT NULL);
  GET DIAGNOSTICS n_add = ROW_COUNT;
  RETURN n_add + n_drop;
END $$;

-- A game tagged to the team → list men get it.
CREATE OR REPLACE FUNCTION fh_roster_game_invites_on_tag()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF EXISTS (SELECT 1 FROM official_roster_sources WHERE games_team_id = NEW.team_id) THEN
    INSERT INTO fh_event_invites (fh_event_id, person_id, from_team_id, recipient_person_id, channel, note)
    SELECT NEW.fh_event_id, gr.person_id, gr.from_team_id, gr.person_id, 'roster', 'official league list'
      FROM fh_roster_game_grants() gr
      JOIN fh_events fe ON fe.id = NEW.fh_event_id AND fe.kind = 'match'
     WHERE gr.team_id = NEW.team_id
       AND NOT EXISTS (SELECT 1 FROM fh_event_invites i WHERE i.fh_event_id = NEW.fh_event_id
                          AND i.person_id = gr.person_id AND (i.revoked_at IS NULL OR (i.channel = 'roster' AND i.revoked_by_user_id IS NOT NULL)));
  END IF;
  RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS trg_roster_game_invites ON fh_event_teams;
CREATE TRIGGER trg_roster_game_invites AFTER INSERT ON fh_event_teams
  FOR EACH ROW EXECUTE FUNCTION fh_roster_game_invites_on_tag();

CREATE OR REPLACE FUNCTION fh_roster_game_restraint_changed()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN PERFORM fh_sync_roster_game_invites(); RETURN NULL; END $$;
DROP TRIGGER IF EXISTS trg_game_restraints_sync ON game_restraints;
CREATE TRIGGER trg_game_restraints_sync AFTER INSERT OR DELETE ON game_restraints
  FOR EACH STATEMENT EXECUTE FUNCTION fh_roster_game_restraint_changed();

-- After every list pull (both pull paths call this once the list is whole).
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
    -- On a list → sees the games unless restrained (mig 1443).
    PERFORM fh_sync_roster_game_invites();
    RETURN n;
END $function$;

CREATE OR REPLACE FUNCTION fh_person_sees(p_ids int[])
RETURNS TABLE (person_id int, sees jsonb, suspended boolean, injured boolean)
LANGUAGE sql STABLE AS $$
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
    SELECT a.person_id, a.team_id FROM team_auto_invites a
     WHERE a.active AND a.person_id = ANY(p_ids)
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
      FROM game_restraints r JOIN board b ON b.id = r.team_id
     WHERE r.person_id = ANY(p_ids)
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
$$;

SELECT fh_sync_roster_game_invites() AS first_sync;
