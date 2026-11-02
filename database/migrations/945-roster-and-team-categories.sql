-- Roster and Team categories on #teams (owner 2026-11-02).
--
-- Roster pill = league only: ON ROSTER, NEEDS ADD, NEEDS DROP, NOT ON ROSTER,
-- and every player on the team shows in one of them.  NEEDS ADD is now a
-- choice: owner, "the only ones that get needs add are guys we want to add".
-- It used to be derived from a blank status, so anyone on a team landed there.
--
-- Team pill = what he does with the team, two new groups:
--   PRACTICE SQUAD: trains, no league games, still asked about practices.
--   INACTIVE: owner, "paying dues and not on roster but may return but i
--     don't want to remind them every day to rsvp".  Still billed, no RSVP
--     asks, and a yes RSVP of his own brings him straight back.
-- Both ride on invite_only (mig 619), so every game gate already applies:
-- no game visibility, lineup pool, fine or game reminder, and practices stay
-- visible and answerable (mig 824).

CREATE TABLE IF NOT EXISTS squad_statuses (
    id                  SERIAL PRIMARY KEY,
    code                TEXT NOT NULL UNIQUE,
    display_name        TEXT NOT NULL,
    owes_practice_rsvps BOOLEAN NOT NULL,
    sort_order          INTEGER NOT NULL DEFAULT 0,
    is_active           BOOLEAN NOT NULL DEFAULT true
);
COMMENT ON TABLE squad_statuses IS 'Team pill groups beyond Plays/Paper/Call-in: a row on team_persons.squad_status_id. owes_practice_rsvps = the RSVP board asks him about practices.';

INSERT INTO squad_statuses (code, display_name, owes_practice_rsvps, sort_order) VALUES
    ('practice_squad', 'Practice Squad', true,  1),
    ('inactive',       'Inactive',       false, 2)
ON CONFLICT (code) DO NOTHING;

ALTER TABLE team_persons ADD COLUMN IF NOT EXISTS squad_status_id INTEGER REFERENCES squad_statuses(id);
COMMENT ON COLUMN team_persons.squad_status_id IS 'Team pill Practice Squad / Inactive for this team, per team; NULL = his group comes from invite_only + call_in. Needs invite_only, which carries the no-game-grants rules.';
ALTER TABLE team_persons DROP CONSTRAINT IF EXISTS team_persons_squad_needs_invite_only;
ALTER TABLE team_persons ADD CONSTRAINT team_persons_squad_needs_invite_only
    CHECK (squad_status_id IS NULL OR invite_only);

-- A youth status change recomputes invite_only (mig 904); keep the squad's.
CREATE OR REPLACE FUNCTION fh_team_persons_games_need_roster() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE on_list boolean;
BEGIN
    IF (SELECT games_need_roster FROM teams WHERE id = NEW.team_id) THEN
        on_list := COALESCE((SELECT counts_as_on_roster FROM roster_statuses WHERE id = NEW.roster_status_id), false)
                OR EXISTS (SELECT 1 FROM official_roster_names n
                             JOIN official_roster_sources s ON s.id = n.source_id
                            WHERE s.team_id = NEW.team_id AND s.is_active AND n.person_id = NEW.person_id);
        NEW.invite_only := NOT on_list OR NEW.squad_status_id IS NOT NULL;
        NEW.call_in     := NOT on_list;
    END IF;
    RETURN NEW;
END $$;

-- An inactive player's own yes brings him back on all his teams.  A standing
-- auto-RSVP is not him answering.  roster_status_id is named so the youth
-- trigger above recomputes invite_only for a kid not on the list.
CREATE OR REPLACE FUNCTION fh_inactive_back_on_yes() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.response = 'yes' AND NEW.created_via <> 'standing' THEN
        UPDATE team_persons tp
           SET squad_status_id = NULL, invite_only = false, call_in = false,
               roster_status_id = tp.roster_status_id
         WHERE tp.person_id = NEW.person_id AND tp.removed_at IS NULL
           AND tp.squad_status_id = (SELECT id FROM squad_statuses WHERE code = 'inactive');
    END IF;
    RETURN NEW;
END $$;
DROP TRIGGER IF EXISTS fh_event_rsvps_inactive_back ON fh_event_rsvps;
CREATE TRIGGER fh_event_rsvps_inactive_back
    AFTER INSERT OR UPDATE OF response ON fh_event_rsvps
    FOR EACH ROW EXECUTE FUNCTION fh_inactive_back_on_yes();

-- The status you pick to send a player to NEEDS ADD: first step of the add
-- lane, offered in every league that has the lane.
INSERT INTO roster_statuses (id, code, display_name, description, show_in_rsvp, show_in_official_roster,
                             sort_order, is_active, color_bg, color_fg, color_border, counts_as_on_roster,
                             player_done, board_section, league_request)
SELECT 14, 'needs_add', 'Needs Add', 'You want him on the league roster — no paperwork step started yet',
       show_in_rsvp, show_in_official_roster, 2, true, color_bg, color_fg, color_border, false, false, 'proposed', 'add'
  FROM roster_statuses WHERE code = 'has_docs'
ON CONFLICT DO NOTHING;
UPDATE roster_statuses SET sort_order = sort_order + 1 WHERE sort_order >= 2 AND code <> 'needs_add';

INSERT INTO league_roster_statuses (league_id, roster_status_id)
SELECT DISTINCT lrs.league_id, (SELECT id FROM roster_statuses WHERE code = 'needs_add')
  FROM league_roster_statuses lrs
  JOIN roster_statuses rs ON rs.id = lrs.roster_status_id
 WHERE rs.board_section = 'proposed'
   AND NOT EXISTS (SELECT 1 FROM league_roster_statuses x
                    WHERE x.league_id = lrs.league_id
                      AND x.roster_status_id = (SELECT id FROM roster_statuses WHERE code = 'needs_add'));

-- League asks: an add is only ever a player you picked.
CREATE OR REPLACE FUNCTION public.fh_league_moves()
 RETURNS TABLE(source_id integer, team_id integer, person_id integer, full_name text, official_no integer, move text, reason text, requested_at timestamp with time zone)
 LANGUAGE sql
 STABLE
AS $function$
  WITH src AS (
    SELECT s.id, s.team_id FROM official_roster_sources s
     WHERE s.is_active AND s.request_contact_id IS NOT NULL
  ), list AS (
    SELECT DISTINCT ON (s.id, n.person_id) s.id AS source_id, s.team_id, n.person_id, n.full_name,
           (row_number() OVER (PARTITION BY s.id ORDER BY n.sort_order, n.id))::int AS official_no
      FROM src s JOIN official_roster_names n ON n.source_id = s.id
     ORDER BY s.id, n.person_id, n.sort_order
  ), live AS (
    SELECT tp.team_id, tp.person_id, tp.invite_only, tp.call_in, rs.code, rs.board_section, rs.league_request
      FROM team_persons tp LEFT JOIN roster_statuses rs ON rs.id = tp.roster_status_id
     WHERE tp.removed_at IS NULL
  ), on_list AS (   -- every mirrored league list, any team
    SELECT s.team_id, n.person_id FROM official_roster_sources s
      JOIN official_roster_names n ON n.source_id = s.id
     WHERE s.is_active AND n.person_id IS NOT NULL
  ), moves AS (
    SELECT l.source_id, l.team_id, l.person_id, l.full_name, l.official_no, 'drop'::text AS move,
           CASE WHEN v.league_request = 'drop' THEN 'drop' ELSE 'cut' END AS reason,
           v.board_section = 'pending_drop' AS asked
      FROM list l LEFT JOIN live v ON v.team_id = l.team_id AND v.person_id = l.person_id
     WHERE l.person_id IS NOT NULL
       AND (v.league_request = 'drop' OR v.board_section = 'pending_drop' OR NOT fh_in_leagueapps(l.person_id))
    UNION ALL
    SELECT s.id, s.team_id, v.person_id,
           trim(COALESCE(p.first_name, '') || ' ' || COALESCE(p.last_name, '')), NULL, 'add',
           CASE WHEN v.code = 'needs_add' THEN 'needs_add' ELSE 'proposed' END, false
      FROM src s JOIN live v ON v.team_id = s.team_id
      JOIN persons p ON p.id = v.person_id
     WHERE NOT EXISTS (SELECT 1 FROM on_list o WHERE o.team_id = s.team_id AND o.person_id = v.person_id)
       -- never while hurt (mig 853): he goes on the list when he's healthy
       AND NOT EXISTS (SELECT 1 FROM person_injuries i JOIN health_statuses h ON h.id = i.health_status_id
                        WHERE i.person_id = v.person_id AND h.is_injured
                          AND i.starts_at <= now() AND (i.ends_at IS NULL OR i.ends_at > now()))
       AND v.league_request = 'add'
  )
  SELECT m.source_id, m.team_id, m.person_id, m.full_name, m.official_no, m.move, m.reason,
         COALESCE((SELECT max(r.requested_at) FROM league_move_requests r
                    WHERE r.source_id = m.source_id AND r.person_id = m.person_id AND r.move = m.move),
                  CASE WHEN m.asked THEN now() END)
    FROM moves m
   ORDER BY m.source_id, m.move DESC, m.official_no NULLS LAST, m.full_name;
$function$;

-- Words (read through MessageCopy).
UPDATE message_templates SET body = v.b
  FROM (VALUES
    ('board_official_h',        'ON ROSTER'),
    ('board_needs_add_h',       'NEEDS ADD'),
    ('board_dropping_h',        'NEEDS DROP'),
    ('board_planned_drop_chip', '⬇ NEEDS DROP'),
    ('board_planned_drops',     '{n} needs drop'),
    ('team_status_title',       'His role on this team — Plays (games, RSVPs, lineups), Practice Squad (trains, no league games), Paper spot (holds the place, plays only when invited), Call-in, Inactive (not practicing, still billed, no RSVP reminders) or injured (every team)')
  ) AS v(t, b)
 WHERE message_templates.kind = 'roster_sheet' AND message_templates.tier = v.t;

INSERT INTO message_templates (category, label, kind, tier, subject, body, sort_order, is_active, client_side, is_public)
SELECT 'Roster sheet', l, 'roster_sheet', t, NULL, b, o, true, true, false
  FROM (VALUES
    ('team_status_practice_squad', 'Team boards — Team dropdown: practice squad', 'Practice Squad', 963),
    ('team_status_inactive',       'Team boards — Team dropdown: inactive',       '💤 Inactive',    964),
    ('board_practice_squad_h',     'Team boards — Team pill section',             'PRACTICE SQUAD', 965),
    ('board_inactive_h',           'Team boards — Team pill section',             '💤 INACTIVE',    966)
  ) AS v(t, l, b, o)
 WHERE NOT EXISTS (SELECT 1 FROM message_templates m WHERE m.kind = 'roster_sheet' AND m.tier = v.t);
