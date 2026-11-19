-- 1528 (2026-11-19) — ⛔ Not On Roster is a flag, not a group; men's 💤 sees games.
--
-- Owner: "i am thinking not on roster needs to go as a cat too. if your not
-- on roster then it should show a flag on your card. so you can move all
-- them to inactive except wafa, corredor or anyone else who responds. they
-- would be on practive squad right?" — after "inactive should be same as
-- not chasing. it just means they are still part of club and still liga 1"
-- and "inactive could see games but they would be on inactive and not no
-- response" ("let them resopnd if they see it and we can use them and get
-- them on roster if needed").
--
-- 1. The mig 1523/1525 auto status goes: trigger dropped, squad status
--    not_eligible retired (is_active false).  Its 10 rows move —
--      never answered an RSVP      → 💤 Inactive   (Kante, Nicolas)
--      answered                    → 🏋 Practice Squad (Wafa, Corredor,
--                                    Castillo, Patino, Jeune; Mars on APSL)
--      APSL Reserves rows of men On Roster for CASA (Dawens, Josue) → no status
-- 2. fh_team_game_eligible(team, person): On Roster on one of the team's
--    team_eligibility_sources (CASA, APSL call-down), or a roster status
--    that says so; a team without sources is always true.  The #teams board
--    and Game Center draw ⛔ Not On Roster from it, whatever the group.
-- 3. squad_status_section_rules.sees_games: men's 💤 Inactive sees the
--    team's games (invite_only false, set by trigger) — still billed, never
--    fined, never in No response / Remind all (owes no RSVPs).  Youth 💤
--    unchanged.

BEGIN;

-- 2 ────────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION fh_team_game_eligible(p_team_id integer, p_person_id integer)
RETURNS boolean LANGUAGE sql STABLE AS $$
  SELECT NOT EXISTS (SELECT 1 FROM team_eligibility_sources WHERE team_id = p_team_id)
      OR EXISTS (SELECT 1 FROM official_roster_names n
                   JOIN team_eligibility_sources e ON e.source_id = n.source_id AND e.team_id = p_team_id
                  WHERE n.person_id = p_person_id)
      OR EXISTS (SELECT 1 FROM team_persons tp JOIN roster_statuses rs ON rs.id = tp.roster_status_id
                  WHERE tp.team_id = p_team_id AND tp.person_id = p_person_id AND tp.removed_at IS NULL
                    AND (rs.counts_as_on_roster OR rs.code = 'suspended'))
$$;
COMMENT ON FUNCTION fh_team_game_eligible(integer, integer) IS
  'mig 1528: On Roster for this team''s games — on one of its team_eligibility_sources official rosters (Liga 1: CASA + APSL call-down) or a roster status that counts as on roster. false = ⛔ Not On Roster flag on his box. A team with no sources: always true.';

-- 1 ────────────────────────────────────────────────────────────────────
DROP TRIGGER IF EXISTS team_persons_eligibility ON team_persons;
DROP FUNCTION IF EXISTS fh_team_persons_eligibility();

CREATE OR REPLACE FUNCTION public.fn_official_names_reread_games()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    UPDATE team_persons tp SET roster_status_id = tp.roster_status_id
      FROM teams t WHERE t.id = tp.team_id AND t.games_need_roster AND tp.removed_at IS NULL;
    RETURN NULL;
END $function$;

-- 3 (before the moves, so the 💤 rows land seeing games) ───────────────
ALTER TABLE squad_status_section_rules ADD COLUMN IF NOT EXISTS sees_games boolean;
COMMENT ON COLUMN squad_status_section_rules.sees_games IS
  'mig 1528: true = this status on this section''s teams still sees the team''s games (invite_only forced false by trigger). NULL = the status''s usual no-games rule.';
INSERT INTO squad_status_section_rules (club_section_id, squad_status_id, owes_practice_rsvps, sees_games)
SELECT cs.id, ss.id, false, true FROM club_sections cs, squad_statuses ss
 WHERE cs.code = 'M' AND ss.code = 'inactive'
ON CONFLICT (club_section_id, squad_status_id) DO UPDATE SET sees_games = true;

-- Replaces CHECK team_persons_squad_needs_invite_only (mig 945: every
-- squad status meant "no games"): a status still means invite_only, unless
-- the section rule says it sees games (men's 💤).
ALTER TABLE team_persons DROP CONSTRAINT IF EXISTS team_persons_squad_needs_invite_only;
CREATE OR REPLACE FUNCTION fh_team_persons_section_sees() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.squad_status_id IS NOT NULL THEN
        NEW.invite_only := NOT COALESCE((SELECT r.sees_games FROM squad_status_section_rules r
                                          JOIN teams t ON t.club_section_id = r.club_section_id
                                         WHERE t.id = NEW.team_id AND r.squad_status_id = NEW.squad_status_id), false);
        IF NOT NEW.invite_only THEN NEW.call_in := false; END IF;
    END IF;
    RETURN NEW;
END $$;
-- zz_: BEFORE triggers fire by name; this one has the last word.
DROP TRIGGER IF EXISTS team_persons_zz_section_sees ON team_persons;
CREATE TRIGGER team_persons_zz_section_sees
  BEFORE INSERT OR UPDATE ON team_persons
  FOR EACH ROW EXECUTE FUNCTION fh_team_persons_section_sees();

-- The moves.
WITH ne AS (SELECT id FROM squad_statuses WHERE code = 'not_eligible'),
     tgt AS (
  SELECT tp.id AS tp_id,
         CASE WHEN tp.team_id = 938 THEN NULL
              WHEN fh_person_needs_onboard(tp.person_id) THEN (SELECT id FROM squad_statuses WHERE code = 'inactive')
              ELSE (SELECT id FROM squad_statuses WHERE code = 'practice_squad') END AS to_status
    FROM team_persons tp, ne WHERE tp.squad_status_id = ne.id AND tp.removed_at IS NULL)
UPDATE team_persons tp
   SET squad_status_id = tgt.to_status,
       invite_only = tgt.to_status IS NOT NULL
  FROM tgt WHERE tp.id = tgt.tp_id;

UPDATE squad_statuses SET is_active = false WHERE code = 'not_eligible';

-- Men's 💤 already set: touch so the trigger opens their games.
UPDATE team_persons tp SET squad_status_id = tp.squad_status_id
  FROM teams t JOIN club_sections cs ON cs.id = t.club_section_id AND cs.code = 'M',
       squad_statuses ss
 WHERE t.id = tp.team_id AND ss.id = tp.squad_status_id AND ss.code = 'inactive' AND tp.removed_at IS NULL;

-- Fines: a Team-pill group owes nothing (men's 💤 now has invite_only false).
CREATE OR REPLACE FUNCTION public.fh_person_fines_all(p_person_ids integer[], p_from timestamp with time zone)
 RETURNS TABLE(person_id integer, fh_event_id bigint, team_id integer, starts_at timestamp with time zone, event_kind text, opponent text, fine_kind text, amount_usd numeric, response text, attendance text)
 LANGUAGE sql
 STABLE
AS $function$
   WITH ev AS MATERIALIZED (
     -- The window's events first (mig 1403): the date filter used to run
     -- last, after every event of every team x every roster row (678k rows
     -- to keep 2.5k, 3 s on #tuition / #fines).
     SELECT fe.id, fe.kind, fe.opponent, ge.starts_at
       FROM gcal_events ge
       JOIN fh_events fe ON fe.gcal_event_id = ge.id
                        AND fe.kind IN ('practice', 'match', 'intrasquad')
      WHERE ge.starts_at >= p_from AND ge.starts_at < now()
        AND ge.deleted_at IS NULL AND ge.status IS DISTINCT FROM 'cancelled'
   ), owed AS (
     SELECT DISTINCT ON (tp.person_id, fe.id)
            tp.person_id, fe.id AS fh_event_id, t.id AS team_id, t.club_id, t.club_section_id,
            fe.starts_at, fe.kind, fe.opponent,
            rv.response, rv.responded_at, att.status AS attendance
       FROM ev fe
       JOIN fh_event_teams fet   ON fet.fh_event_id = fe.id
       JOIN teams t              ON t.id = fet.team_id AND t.is_active
       JOIN team_persons tp      ON tp.team_id = t.id
       LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
       LEFT JOIN fh_event_rsvps rv       ON rv.fh_event_id = fe.id  AND rv.person_id  = tp.person_id
       LEFT JOIN fh_event_attendance att ON att.fh_event_id = fe.id AND att.person_id = tp.person_id
      WHERE tp.person_id = ANY (p_person_ids)
        AND tp.removed_at IS NULL
        -- Call-up-gated team (mig 603): being on the roster creates no
        -- expectation, so no fine. Invited call-ups are deliberately not
        -- fined either (youth semantics).
        AND NOT fh_team_callup_only(tp.team_id)
        AND NOT tp.invite_only  -- mig 619: paper spots owe nothing
        AND tp.squad_status_id IS NULL  -- mig 1528: a Team-pill group (men's 💤 sees games) owes nothing
        AND t.club_section_id IS NOT NULL
        AND fe.starts_at >= GREATEST(tp.joined_at, p_from)
      ORDER BY tp.person_id, fe.id, t.id
   ), judged AS (
     SELECT o.*,
            CASE
              WHEN o.response IS NULL OR o.responded_at >= o.starts_at
                THEN CASE WHEN o.kind = 'practice' THEN 'missed_rsvp_practice' ELSE 'missed_rsvp_game' END
              WHEN o.response = 'yes' AND o.attendance = 'absent'
                THEN CASE WHEN o.kind = 'practice' THEN 'no_show_practice' ELSE 'no_show_game' END
            END AS fine_kind
       FROM owed o
   ), fined AS MATERIALIZED (
     -- Only rows that would be fined go through the per-person checks
     -- below (mig 1249): they are the expensive part, and most event rows
     -- are answered in time.
     SELECT * FROM judged WHERE fine_kind IS NOT NULL
   ), kept AS (
     SELECT f.* FROM fined f
      WHERE NOT fh_event_suspended(f.fh_event_id, f.person_id)        -- ⛔ suspended for this game (mig 1077)
        AND fh_dues_eligible_at(f.person_id, f.club_id, f.starts_at)  -- dues blocked that day (mig 461)
        AND NOT fh_fine_exempt(f.person_id)                            -- coaches (mig 693)
        AND NOT fh_person_injured_at(f.person_id, f.starts_at)         -- injured that day (mig 510)
   )
   SELECT j.person_id, j.fh_event_id, j.team_id, j.starts_at, j.kind, j.opponent,
          j.fine_kind, amt.amount_usd, j.response, j.attendance
     FROM kept j
     CROSS JOIN LATERAL (
       SELECT fh_fine_amount_usd(j.club_id, j.club_section_id, j.fine_kind,
                                 (j.starts_at AT TIME ZONE 'America/New_York')::date) AS amount_usd
     ) amt
    WHERE amt.amount_usd IS NOT NULL AND amt.amount_usd > 0
 $function$;

-- fh_person_sees: men's 💤 sees games, still noted 💤.
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
           -- mig 1528: men's 💤 Inactive still sees games (squad_status_section_rules.sees_games)
           ((ss.code = 'inactive' AND NOT COALESCE((SELECT r.sees_games FROM squad_status_section_rules r
                                                     WHERE r.squad_status_id = ss.id AND r.club_section_id = b.club_section_id), false))
            OR (ss.id IS NULL AND tp.invite_only AND NOT b.games_need_roster)) AS idle,
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
           CASE WHEN p.idle OR p.squad = 'inactive' THEN 'inactive'
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
